% Input: fault_id
% Output: Validate fault configuration mapping
% Pos: tests/test_set_fault_mode.m

function test_set_fault_mode()
    cfg_none = set_fault_mode(0);
    assert(strcmp(cfg_none.name, 'none'), 'fault 0 should be none');

    cfg_bus = set_fault_mode(1);
    assert(strcmp(cfg_bus.name, 'bus_short'), 'fault 1 should be bus_short');
    assert(abs(cfg_bus.trigger_time - 0.6) < 1e-12, 'fault trigger time mismatch');

    cfg_pos = set_fault_mode(2);
    assert(strcmp(cfg_pos.name, 'pos_ground'), 'fault 2 should be pos_ground');

    cfg_neg = set_fault_mode(3);
    assert(strcmp(cfg_neg.name, 'neg_ground'), 'fault 3 should be neg_ground');
end
