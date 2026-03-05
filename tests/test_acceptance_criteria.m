% Input: run_case_simulation for mode/fault scenarios
% Output: Validate core acceptance constraints from project spec
% Pos: tests/test_acceptance_criteria.m

function test_acceptance_criteria()
    vdc_ref = 1500;
    vdc_tol = 0.01 * vdc_ref;
    settle_t0 = 0.8;

    for mode_id = 1:4
        out_mode = run_case_simulation(mode_id, 0, 1.0);
        idx_settle = out_mode.t >= settle_t0;
        vdc_settle = out_mode.Vdc(idx_settle);

        assert(~isempty(vdc_settle), sprintf('mode%d missing steady-state window', mode_id));

        max_err = max(abs(vdc_settle - vdc_ref));
        assert(max_err <= vdc_tol, ...
            sprintf('O1 failed mode%d: steady-state max error %.3fV exceeds %.3fV', ...
            mode_id, max_err, vdc_tol));

        ripple_pp = max(vdc_settle) - min(vdc_settle);
        assert(ripple_pp <= 2 * vdc_tol, ...
            sprintf('O2 failed mode%d: steady-state ripple %.3fV exceeds %.3fV', ...
            mode_id, ripple_pp, 2 * vdc_tol));
    end

    out_transition = run_case_simulation(4, 0, 1.0, 2);
    t_recover = compute_recovery_time(out_transition.t, out_transition.Vdc, vdc_ref, vdc_tol, 0.5);
    assert(t_recover <= 0.3, ...
        sprintf('O4 failed: WC2->WC4 recovery %.4fs exceeds 0.3s', t_recover));

    fault_bus = run_case_simulation(1, 1, 1.0);
    idx_fault = fault_bus.t >= 0.6 & fault_bus.t <= 0.65;
    assert(min(fault_bus.Vdc(idx_fault)) < 900, 'O5 failed: bus short drop not obvious');

    fault_pos = run_case_simulation(1, 2, 1.0);
    idx_fault_pos = fault_pos.t >= 0.6 & fault_pos.t <= 0.65;
    assert(max(abs(fault_pos.V_pos_gnd(idx_fault_pos))) < 50, 'O5 failed: pos-ground voltage not near 0V');
    assert(abs(mean(fault_pos.V_neg_gnd(idx_fault_pos)) + vdc_ref) < 80, ...
        'O5 failed: pos-ground fault should lift negative pole near -1500V');

    % M5.3 threshold rationale:
    % 1) ratio >= 1.20: no-inductor case must be at least 20% steeper than with-inductor.
    % 2) delta >= 1e4 A/s: avoid tiny numerical differences being misclassified as physical effect.
    didt_ratio_threshold = 1.20;
    didt_delta_threshold = 1e4;
    with_inductor = run_case_simulation(1, 1, 1.0, 1, struct('with_inductor', true));
    without_inductor = run_case_simulation(1, 1, 1.0, 1, struct('with_inductor', false));
    didt_with = compute_fault_didt(with_inductor.t, with_inductor.I_fault_total, 0.6, 0.65);
    didt_without = compute_fault_didt(without_inductor.t, without_inductor.I_fault_total, 0.6, 0.65);
    assert(didt_without > didt_with, ...
        sprintf('M5.3 failed: dI/dt without inductor %.3f <= with inductor %.3f', didt_without, didt_with));
    assert(didt_without >= didt_with * didt_ratio_threshold, ...
        sprintf('M5.3 failed: ratio %.3f < %.3f', didt_without / didt_with, didt_ratio_threshold));
    assert((didt_without - didt_with) >= didt_delta_threshold, ...
        sprintf('M5.3 failed: delta %.3f A/s < %.3f A/s', ...
        didt_without - didt_with, didt_delta_threshold));
end

function t_recover = compute_recovery_time(t, vdc, vref, tol, t_step)
    idx_after = find(t >= t_step, 1, 'first');
    t_recover = inf;
    if isempty(idx_after)
        return;
    end

    for k = idx_after:numel(t)
        if all(abs(vdc(k:end) - vref) <= tol)
            t_recover = t(k) - t_step;
            return;
        end
    end
end

function didt_peak = compute_fault_didt(t, current, t_start, t_end)
    idx = t >= t_start & t <= t_end;
    t_window = t(idx);
    i_window = current(idx);
    if numel(t_window) < 3
        error('M5.3 failed: insufficient samples in fault window for dI/dt.');
    end

    dt = diff(t_window);
    di = diff(i_window);
    didt = di ./ dt;
    didt_peak = max(didt);
end
