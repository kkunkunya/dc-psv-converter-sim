% Input: run_case_simulation for mode/fault scenarios
% Output: Validate core acceptance constraints from project spec
% Pos: tests/test_acceptance_criteria.m

function test_acceptance_criteria()
    out1 = run_case_simulation(1, 0, 1.0);

    idx_after_02 = out1.t >= 0.2;
    vdc_after_02 = out1.Vdc(idx_after_02);
    assert(all(abs(vdc_after_02 - 1500) <= 15), 'O1 failed: Vdc out of ±1%% after 0.2s');

    out4 = run_case_simulation(4, 0, 1.0);
    idx_after_switch = out4.t >= 0.8;
    vdc_after_switch = out4.Vdc(idx_after_switch);
    assert(all(abs(vdc_after_switch - mean(vdc_after_switch)) < 20), 'O4 failed: mode switch not stable by 0.8s');

    fault_bus = run_case_simulation(1, 1, 1.0);
    idx_fault = fault_bus.t >= 0.6 & fault_bus.t <= 0.65;
    assert(min(fault_bus.Vdc(idx_fault)) < 900, 'O5 failed: bus short drop not obvious');

    fault_pos = run_case_simulation(1, 2, 1.0);
    idx_fault_pos = fault_pos.t >= 0.6 & fault_pos.t <= 0.65;
    assert(max(abs(fault_pos.V_pos_gnd(idx_fault_pos))) < 50, 'O5 failed: pos-ground voltage not near 0V');
end
