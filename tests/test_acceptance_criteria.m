% Input: run_case_simulation for mode/fault scenarios
% Output: Validate core acceptance constraints from project spec
% Pos: tests/test_acceptance_criteria.m

function test_acceptance_criteria()
    vdc_ref = 1500;
    vdc_tol = 0.01 * vdc_ref;
    settle_t0 = 0.8;
    % O3阈值工程依据：
    % 1) midpoint_abs_tol=20V（约母线1500V的1.3%），给求解器离散误差和数值噪声留余量。
    % 2) halfbus_err_tol=10V（约半母线750V的1.3%），可约束中点分压对称且不过度苛刻。
    midpoint_abs_tol = 20;
    halfbus_err_tol = 10;

    for mode_id = 1:4
        out_mode = run_case_simulation(mode_id, 0, 1.0);
        idx_settle = out_mode.t >= settle_t0;
        vdc_settle = out_mode.Vdc(idx_settle);
        v_pos_settle = out_mode.V_pos_gnd(idx_settle);
        v_neg_settle = out_mode.V_neg_gnd(idx_settle);

        assert(~isempty(vdc_settle), sprintf('mode%d missing steady-state window', mode_id));

        max_err = max(abs(vdc_settle - vdc_ref));
        assert(max_err <= vdc_tol, ...
            sprintf('O1 failed mode%d: steady-state max error %.3fV exceeds %.3fV', ...
            mode_id, max_err, vdc_tol));

        ripple_pp = max(vdc_settle) - min(vdc_settle);
        assert(ripple_pp <= 2 * vdc_tol, ...
            sprintf('O2 failed mode%d: steady-state ripple %.3fV exceeds %.3fV', ...
            mode_id, ripple_pp, 2 * vdc_tol));

        midpoint_abs_max = max(abs(v_pos_settle + v_neg_settle));
        vpos_halfbus_err_max = max(abs(v_pos_settle - 0.5 * vdc_settle));
        vneg_halfbus_err_max = max(abs(v_neg_settle + 0.5 * vdc_settle));
        assert(midpoint_abs_max <= midpoint_abs_tol, ...
            sprintf('O3 failed mode%d: |Vpos+Vneg| max %.3fV exceeds %.3fV', ...
            mode_id, midpoint_abs_max, midpoint_abs_tol));
        assert(vpos_halfbus_err_max <= halfbus_err_tol, ...
            sprintf('O3 failed mode%d: Vpos-halfbus error max %.3fV exceeds %.3fV', ...
            mode_id, vpos_halfbus_err_max, halfbus_err_tol));
        assert(vneg_halfbus_err_max <= halfbus_err_tol, ...
            sprintf('O3 failed mode%d: Vneg-halfbus error max %.3fV exceeds %.3fV', ...
            mode_id, vneg_halfbus_err_max, halfbus_err_tol));
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

    validate_o3_summary_columns(midpoint_abs_tol, halfbus_err_tol);
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

function validate_o3_summary_columns(midpoint_abs_tol, halfbus_err_tol)
    this_file = mfilename('fullpath');
    root_dir = fileparts(fileparts(this_file));
    summary_path = fullfile(root_dir, 'data', 'summary_results.csv');
    assert(isfile(summary_path), 'O3 failed: summary_results.csv not found.');

    summary_tbl = readtable(summary_path, 'VariableNamingRule', 'preserve');
    required_cols = {'midpoint_abs_max_v', 'vpos_halfbus_err_max_v', 'vneg_halfbus_err_max_v'};
    for k = 1:numel(required_cols)
        assert(ismember(required_cols{k}, summary_tbl.Properties.VariableNames), ...
            sprintf('O3 failed: summary missing column %s', required_cols{k}));
    end

    mode_cases = {'mode1_cruise_low', 'mode2_cruise_high', 'mode3_dp_normal', 'mode4_dp_harsh'};
    for k = 1:numel(mode_cases)
        row_idx = strcmp(summary_tbl.('case'), mode_cases{k});
        assert(any(row_idx), sprintf('O3 failed: summary missing case %s', mode_cases{k}));
        row = find(row_idx, 1, 'first');

        midpoint_val = summary_tbl.midpoint_abs_max_v(row);
        vpos_err_val = summary_tbl.vpos_halfbus_err_max_v(row);
        vneg_err_val = summary_tbl.vneg_halfbus_err_max_v(row);
        assert(isfinite(midpoint_val) && midpoint_val <= midpoint_abs_tol, ...
            sprintf('O3 failed %s: midpoint_abs_max_v %.3fV exceeds %.3fV', ...
            mode_cases{k}, midpoint_val, midpoint_abs_tol));
        assert(isfinite(vpos_err_val) && vpos_err_val <= halfbus_err_tol, ...
            sprintf('O3 failed %s: vpos_halfbus_err_max_v %.3fV exceeds %.3fV', ...
            mode_cases{k}, vpos_err_val, halfbus_err_tol));
        assert(isfinite(vneg_err_val) && vneg_err_val <= halfbus_err_tol, ...
            sprintf('O3 failed %s: vneg_halfbus_err_max_v %.3fV exceeds %.3fV', ...
            mode_cases{k}, vneg_err_val, halfbus_err_tol));
    end
end
