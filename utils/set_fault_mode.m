% Input: fault_id (0:none,1:bus_short,2:pos_ground,3:neg_ground)
% Output: fault configuration struct
% Pos: utils/set_fault_mode.m

function cfg = set_fault_mode(fault_id)
    validateattributes(fault_id, {'numeric'}, {'scalar', 'integer', '>=', 0, '<=', 3});

    cfg = struct();
    cfg.id = fault_id;
    cfg.trigger_time = 0.6;
    cfg.duration = 0.05;

    switch fault_id
        case 0
            cfg.name = 'none';
            cfg.resistance_ohm = inf;
            cfg.vdc_scale = 1.0;
        case 1
            cfg.name = 'bus_short';
            cfg.resistance_ohm = 0.01;
            cfg.vdc_scale = 0.30;
        case 2
            cfg.name = 'pos_ground';
            cfg.resistance_ohm = 0.1;
            cfg.vdc_scale = 1.0;
        case 3
            cfg.name = 'neg_ground';
            cfg.resistance_ohm = 0.1;
            cfg.vdc_scale = 1.0;
    end
end
