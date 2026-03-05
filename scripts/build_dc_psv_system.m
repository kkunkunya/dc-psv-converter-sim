% Input: base workspace vars mode_id_sim, fault_id_sim, sim_params
% Output: models/dc_psv_system.slx generated and saved with layered topology
% Pos: scripts/build_dc_psv_system.m

function model_path = build_dc_psv_system()
    root_dir = fileparts(fileparts(mfilename('fullpath')));
    model_name = 'dc_psv_system';
    models_dir = fullfile(root_dir, 'models');
    model_path = fullfile(models_dir, [model_name '.slx']);

    if ~exist(models_dir, 'dir')
        mkdir(models_dir);
    end

    if bdIsLoaded(model_name)
        close_system(model_name, 0);
    end

    new_system(model_name);
    open_system(model_name);

    set_param(model_name, 'Solver', 'ode4');
    set_param(model_name, 'FixedStep', '5e-5');
    set_param(model_name, 'StopTime', '1.0');

    % Top-level sources
    add_block('simulink/Sources/Clock', [model_name '/Clock'], ...
        'Position', [40 60 70 90]);
    add_block('simulink/Sources/Constant', [model_name '/Mode_ID_Target'], ...
        'Value', 'mode_id_sim', 'Position', [40 130 130 160]);
    add_block('simulink/Sources/Constant', [model_name '/Mode_ID_Base'], ...
        'Value', 'mode_base_sim', 'Position', [40 165 130 195]);
    add_block('simulink/Sources/Constant', [model_name '/Fault_ID'], ...
        'Value', 'fault_id_sim', 'Position', [40 235 130 265]);

    % Top-level functional subsystems
    add_block('simulink/Ports & Subsystems/Subsystem', [model_name '/Control_Subsystem'], ...
        'Position', [190 105 370 195]);
    create_control_subsystem([model_name '/Control_Subsystem']);

    add_block('simulink/Ports & Subsystems/Subsystem', [model_name '/Generation_Subsystem'], ...
        'Position', [430 40 690 220]);
    create_generation_subsystem([model_name '/Generation_Subsystem']);

    add_block('simulink/Ports & Subsystems/Subsystem', [model_name '/Load_Subsystem'], ...
        'Position', [430 250 690 500]);
    create_load_subsystem([model_name '/Load_Subsystem']);

    add_block('simulink/Ports & Subsystems/Subsystem', [model_name '/Fault_Subsystem'], ...
        'Position', [760 250 1010 420]);
    create_fault_subsystem([model_name '/Fault_Subsystem']);

    add_block('simulink/Ports & Subsystems/Subsystem', [model_name '/DC_Bus_Subsystem'], ...
        'Position', [760 40 1010 220]);
    create_bus_subsystem([model_name '/DC_Bus_Subsystem']);

    add_block('simulink/Ports & Subsystems/Subsystem', [model_name '/GroundMonitor_Subsystem'], ...
        'Position', [1080 110 1310 280]);
    create_ground_monitor_subsystem([model_name '/GroundMonitor_Subsystem']);

    % Outputs
    add_to_workspace(model_name, 'Vdc_ToWorkspace', 'Vdc', [1360 55 1490 85]);
    add_to_workspace(model_name, 'Idc_ToWorkspace', 'Idc', [1360 95 1490 125]);
    add_to_workspace(model_name, 'V_pos_ToWorkspace', 'V_pos_gnd', [1360 140 1490 170]);
    add_to_workspace(model_name, 'V_neg_ToWorkspace', 'V_neg_gnd', [1360 185 1490 215]);
    add_to_workspace(model_name, 'I_gen_ToWorkspace', 'I_gen_total', [1360 230 1490 260]);
    add_to_workspace(model_name, 'I_load_ToWorkspace', 'I_load_total', [1360 275 1490 305]);
    add_to_workspace(model_name, 'I_fault_ToWorkspace', 'I_fault_total', [1360 320 1490 350]);

    % Top-level connections
    add_line(model_name, 'Mode_ID_Target/1', 'Control_Subsystem/1', 'autorouting', 'smart');
    add_line(model_name, 'Mode_ID_Base/1', 'Control_Subsystem/2', 'autorouting', 'smart');

    add_line(model_name, 'Control_Subsystem/1', 'Load_Subsystem/1', 'autorouting', 'smart');
    add_line(model_name, 'Control_Subsystem/1', 'Generation_Subsystem/2', 'autorouting', 'smart');

    add_line(model_name, 'Clock/1', 'Fault_Subsystem/1', 'autorouting', 'smart');
    add_line(model_name, 'Fault_ID/1', 'Fault_Subsystem/2', 'autorouting', 'smart');

    add_line(model_name, 'Generation_Subsystem/1', 'DC_Bus_Subsystem/1', 'autorouting', 'smart');
    add_line(model_name, 'Load_Subsystem/1', 'DC_Bus_Subsystem/2', 'autorouting', 'smart');
    add_line(model_name, 'Fault_Subsystem/1', 'DC_Bus_Subsystem/3', 'autorouting', 'smart');

    add_line(model_name, 'DC_Bus_Subsystem/1', 'Generation_Subsystem/1', 'autorouting', 'smart');
    add_line(model_name, 'DC_Bus_Subsystem/1', 'Fault_Subsystem/3', 'autorouting', 'smart');
    add_line(model_name, 'DC_Bus_Subsystem/1', 'GroundMonitor_Subsystem/1', 'autorouting', 'smart');

    add_line(model_name, 'Fault_Subsystem/2', 'GroundMonitor_Subsystem/2', 'autorouting', 'smart');
    add_line(model_name, 'Fault_Subsystem/3', 'GroundMonitor_Subsystem/3', 'autorouting', 'smart');

    add_line(model_name, 'DC_Bus_Subsystem/1', 'Vdc_ToWorkspace/1', 'autorouting', 'smart');
    add_line(model_name, 'DC_Bus_Subsystem/2', 'Idc_ToWorkspace/1', 'autorouting', 'smart');
    add_line(model_name, 'GroundMonitor_Subsystem/1', 'V_pos_ToWorkspace/1', 'autorouting', 'smart');
    add_line(model_name, 'GroundMonitor_Subsystem/2', 'V_neg_ToWorkspace/1', 'autorouting', 'smart');
    add_line(model_name, 'Generation_Subsystem/1', 'I_gen_ToWorkspace/1', 'autorouting', 'smart');
    add_line(model_name, 'Load_Subsystem/1', 'I_load_ToWorkspace/1', 'autorouting', 'smart');
    add_line(model_name, 'Fault_Subsystem/1', 'I_fault_ToWorkspace/1', 'autorouting', 'smart');

    save_system(model_name, model_path);
    close_system(model_name, 0);
end

function add_to_workspace(model_name, blk_name, var_name, pos)
    add_block('simulink/Sinks/To Workspace', [model_name '/' blk_name], ...
        'VariableName', var_name, 'SaveFormat', 'Timeseries', 'Position', pos);
end

function create_control_subsystem(path)
    clear_subsystem(path);

    add_block('simulink/Sources/Step', [path '/Mode_Switch_Step'], ...
        'Time', '0.5', 'Before', '0', 'After', '1', 'Position', [40 45 90 75]);

    add_block('simulink/Ports & Subsystems/In1', [path '/Mode_Target_In'], ...
        'Position', [20 115 40 135]);
    add_block('simulink/Ports & Subsystems/In1', [path '/Mode_Base_In'], ...
        'Position', [20 165 40 185]);
    add_block('simulink/Signal Routing/Switch', [path '/Mode_Selector'], ...
        'Criteria', 'u2 >= Threshold', 'Threshold', '0.5', ...
        'Position', [160 85 220 145]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/Mode_Active_Out'], ...
        'Position', [280 105 300 125]);

    add_line(path, 'Mode_Target_In/1', 'Mode_Selector/1', 'autorouting', 'smart');
    add_line(path, 'Mode_Switch_Step/1', 'Mode_Selector/2', 'autorouting', 'smart');
    add_line(path, 'Mode_Base_In/1', 'Mode_Selector/3', 'autorouting', 'smart');
    add_line(path, 'Mode_Selector/1', 'Mode_Active_Out/1', 'autorouting', 'smart');
end

function create_generation_subsystem(path)
    clear_subsystem(path);

    add_block('simulink/Ports & Subsystems/In1', [path '/Vdc_Feedback_In'], ...
        'Position', [20 95 40 115]);
    add_block('simulink/Ports & Subsystems/In1', [path '/Mode_Active_In'], ...
        'Position', [20 155 40 175]);

    dg_names = {'DG1_Branch', 'DG2_Branch', 'DG3_Branch', 'DG4_Branch'};
    vref = [1500, 1498, 1502, 1501];
    ibias_by_mode = [630, 1050, 365, 605];
    ypos = [20, 95, 170, 245];
    for i = 1:4
        add_block('simulink/Ports & Subsystems/Subsystem', [path '/' dg_names{i}], ...
            'Position', [120 ypos(i) 320 ypos(i)+60]);
        create_dg_branch([path '/' dg_names{i}], vref(i), ibias_by_mode);
    end

    add_block('simulink/Math Operations/Sum', [path '/Igen_Sum'], ...
        'Inputs', '++++', 'Position', [380 95 400 235]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/I_gen_total_Out'], ...
        'Position', [460 150 480 170]);

    for i = 1:4
        add_line(path, 'Vdc_Feedback_In/1', [dg_names{i} '/1'], 'autorouting', 'smart');
        add_line(path, 'Mode_Active_In/1', [dg_names{i} '/2'], 'autorouting', 'smart');
        add_line(path, [dg_names{i} '/1'], ['Igen_Sum/' num2str(i)], 'autorouting', 'smart');
    end
    add_line(path, 'Igen_Sum/1', 'I_gen_total_Out/1', 'autorouting', 'smart');
end

function create_dg_branch(path, vref, ibias_by_mode)
    clear_subsystem(path);

    add_block('simulink/Ports & Subsystems/In1', [path '/Vdc_In'], ...
        'Position', [20 40 40 60]);
    add_block('simulink/Ports & Subsystems/In1', [path '/Mode_In'], ...
        'Position', [20 115 40 135]);
    add_block('simulink/Sources/Constant', [path '/Vref'], ...
        'Value', num2str(vref), 'Position', [20 5 80 25]);

    add_block('simulink/Math Operations/Sum', [path '/Verr'], ...
        'Inputs', '+-', 'Position', [100 25 120 75]);
    add_block('simulink/Math Operations/Gain', [path '/Kp'], ...
        'Gain', '0.7', 'Position', [150 20 210 50]);
    add_block('simulink/Math Operations/Gain', [path '/Ki'], ...
        'Gain', '5', 'Position', [150 70 210 100]);
    add_block('simulink/Continuous/Integrator', [path '/Integrator'], ...
        'InitialCondition', '0', 'Position', [235 70 265 100]);
    for m = 1:4
        add_block('simulink/Logic and Bit Operations/Compare To Constant', ...
            [path '/ModeEq' num2str(m)], ...
            'const', num2str(m), 'relop', '==', ...
            'Position', [70 115 + (m-1)*25 130 136 + (m-1)*25]);
        add_block('simulink/Signal Attributes/Data Type Conversion', ...
            [path '/ModeEq' num2str(m) '_ToDouble'], ...
            'OutDataTypeStr', 'double', ...
            'Position', [136 115 + (m-1)*25 155 136 + (m-1)*25]);
        add_block('simulink/Math Operations/Gain', [path '/Ibias' num2str(m)], ...
            'Gain', num2str(ibias_by_mode(m)), ...
            'Position', [165 115 + (m-1)*25 235 136 + (m-1)*25]);
    end
    add_block('simulink/Math Operations/Sum', [path '/Ibias_Sum'], ...
        'Inputs', '++++', 'Position', [265 140 285 220]);
    add_block('simulink/Math Operations/Sum', [path '/PI_plus_bias'], ...
        'Inputs', '+++', 'Position', [315 45 335 105]);
    add_block('simulink/Discontinuities/Saturation', [path '/I_Sat'], ...
        'UpperLimit', '2600', 'LowerLimit', '0', 'Position', [360 55 410 95]);
    add_block('simulink/Continuous/Transfer Fcn', [path '/Lrect_Dynamics'], ...
        'Numerator', '[1]', 'Denominator', '[Lrect_tau_sim 1]', 'Position', [440 55 520 95]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/Iout'], ...
        'Position', [560 65 580 85]);

    add_line(path, 'Vref/1', 'Verr/1', 'autorouting', 'smart');
    add_line(path, 'Vdc_In/1', 'Verr/2', 'autorouting', 'smart');
    add_line(path, 'Verr/1', 'Kp/1', 'autorouting', 'smart');
    add_line(path, 'Verr/1', 'Ki/1', 'autorouting', 'smart');
    add_line(path, 'Ki/1', 'Integrator/1', 'autorouting', 'smart');
    add_line(path, 'Kp/1', 'PI_plus_bias/1', 'autorouting', 'smart');
    add_line(path, 'Integrator/1', 'PI_plus_bias/2', 'autorouting', 'smart');
    for m = 1:4
        add_line(path, 'Mode_In/1', ['ModeEq' num2str(m) '/1'], 'autorouting', 'smart');
        add_line(path, ['ModeEq' num2str(m) '/1'], ...
            ['ModeEq' num2str(m) '_ToDouble/1'], 'autorouting', 'smart');
        add_line(path, ['ModeEq' num2str(m) '_ToDouble/1'], ...
            ['Ibias' num2str(m) '/1'], 'autorouting', 'smart');
        add_line(path, ['Ibias' num2str(m) '/1'], ['Ibias_Sum/' num2str(m)], 'autorouting', 'smart');
    end
    add_line(path, 'Ibias_Sum/1', 'PI_plus_bias/3', 'autorouting', 'smart');
    add_line(path, 'PI_plus_bias/1', 'I_Sat/1', 'autorouting', 'smart');
    add_line(path, 'I_Sat/1', 'Lrect_Dynamics/1', 'autorouting', 'smart');
    add_line(path, 'Lrect_Dynamics/1', 'Iout/1', 'autorouting', 'smart');
end

function create_load_subsystem(path)
    clear_subsystem(path);

    add_block('simulink/Ports & Subsystems/In1', [path '/Mode_Active_In'], ...
        'Position', [20 185 40 205]);

    branch_defs = {
        'MP1_Branch',       [666.6667, 1666.6667,   0.0000,   0.0000];
        'MP2_Branch',       [666.6667, 1666.6667,   0.0000,   0.0000];
        'TT1_Branch',       [  0.0000,    0.0000, 200.0000, 533.3333];
        'TT2_Branch',       [  0.0000,    0.0000, 200.0000, 533.3333];
        'RT_Branch',        [  0.0000,    0.0000, 200.0000, 533.3333];
        'HotelHigh_Branch', [666.6667,  666.6667, 666.6667, 666.6667];
        'HotelLow_Branch',  [180.0000,  180.0000, 180.0000, 180.0000];
        'ESS_Branch',       [  0.0000,    0.0000,   0.0000, -33.3333]
    };

    y = 20;
    for i = 1:size(branch_defs, 1)
        bname = branch_defs{i, 1};
        bvals = branch_defs{i, 2};
        add_block('simulink/Ports & Subsystems/Subsystem', [path '/' bname], ...
            'Position', [120 y 350 y+60]);
        create_load_branch([path '/' bname], bvals);
        y = y + 60;
    end

    add_block('simulink/Math Operations/Sum', [path '/Iload_Sum'], ...
        'Inputs', '++++++++', 'Position', [410 180 430 330]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/I_load_total_Out'], ...
        'Position', [500 245 520 265]);

    for i = 1:size(branch_defs, 1)
        bname = branch_defs{i, 1};
        add_line(path, 'Mode_Active_In/1', [bname '/1'], 'autorouting', 'smart');
        add_line(path, [bname '/1'], ['Iload_Sum/' num2str(i)], 'autorouting', 'smart');
    end
    add_line(path, 'Iload_Sum/1', 'I_load_total_Out/1', 'autorouting', 'smart');
end

function create_load_branch(path, mode_currents)
    clear_subsystem(path);

    add_block('simulink/Ports & Subsystems/In1', [path '/Mode_In'], ...
        'Position', [20 85 40 105]);

    for m = 1:4
        add_block('simulink/Logic and Bit Operations/Compare To Constant', ...
            [path '/ModeEq' num2str(m)], ...
            'const', num2str(m), 'relop', '==', ...
            'Position', [70 15 + (m-1)*35 130 40 + (m-1)*35]);
        add_block('simulink/Signal Attributes/Data Type Conversion', ...
            [path '/ModeEq' num2str(m) '_ToDouble'], ...
            'OutDataTypeStr', 'double', ...
            'Position', [138 15 + (m-1)*35 155 40 + (m-1)*35]);
        add_block('simulink/Math Operations/Gain', [path '/I' num2str(m) '_Weight'], ...
            'Gain', num2str(mode_currents(m)), ...
            'Position', [170 15 + (m-1)*35 230 40 + (m-1)*35]);

        add_line(path, 'Mode_In/1', ['ModeEq' num2str(m) '/1'], 'autorouting', 'smart');
        add_line(path, ['ModeEq' num2str(m) '/1'], ['ModeEq' num2str(m) '_ToDouble/1'], 'autorouting', 'smart');
        add_line(path, ['ModeEq' num2str(m) '_ToDouble/1'], ['I' num2str(m) '_Weight/1'], 'autorouting', 'smart');
    end

    add_block('simulink/Math Operations/Sum', [path '/Iref_Sum'], ...
        'Inputs', '++++', 'Position', [255 55 275 155]);
    add_block('simulink/Continuous/Transfer Fcn', [path '/Load_Dynamics'], ...
        'Numerator', '[1]', 'Denominator', '[0.03 1]', ...
        'Position', [305 85 390 125]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/Iout'], ...
        'Position', [430 95 450 115]);

    for m = 1:4
        add_line(path, ['I' num2str(m) '_Weight/1'], ['Iref_Sum/' num2str(m)], 'autorouting', 'smart');
    end
    add_line(path, 'Iref_Sum/1', 'Load_Dynamics/1', 'autorouting', 'smart');
    add_line(path, 'Load_Dynamics/1', 'Iout/1', 'autorouting', 'smart');
end

function create_fault_subsystem(path)
    clear_subsystem(path);

    add_block('simulink/Ports & Subsystems/In1', [path '/Clock_In'], ...
        'Position', [20 30 40 50]);
    add_block('simulink/Ports & Subsystems/In1', [path '/Fault_ID_In'], ...
        'Position', [20 90 40 110]);
    add_block('simulink/Ports & Subsystems/In1', [path '/Vdc_In'], ...
        'Position', [20 150 40 170]);

    add_block('simulink/Sources/Constant', [path '/Fault_On_Time'], ...
        'Value', '0.6', 'Position', [75 10 125 30]);
    add_block('simulink/Sources/Constant', [path '/Fault_Off_Time'], ...
        'Value', '0.65', 'Position', [75 50 125 70]);

    add_block('simulink/Logic and Bit Operations/Relational Operator', [path '/t_ge_on'], ...
        'Operator', '>=', 'Position', [150 15 190 45]);
    add_block('simulink/Logic and Bit Operations/Relational Operator', [path '/t_le_off'], ...
        'Operator', '<=', 'Position', [150 55 190 85]);
    add_block('simulink/Logic and Bit Operations/Logical Operator', [path '/fault_window'], ...
        'Operator', 'AND', 'Position', [220 30 255 70]);

    add_block('simulink/Logic and Bit Operations/Compare To Constant', [path '/is_bus_short'], ...
        'const', '1', 'relop', '==', 'Position', [300 15 355 45]);
    add_block('simulink/Logic and Bit Operations/Compare To Constant', [path '/is_pos_ground'], ...
        'const', '2', 'relop', '==', 'Position', [300 55 355 85]);
    add_block('simulink/Logic and Bit Operations/Compare To Constant', [path '/is_neg_ground'], ...
        'const', '3', 'relop', '==', 'Position', [300 95 355 125]);

    add_block('simulink/Logic and Bit Operations/Logical Operator', [path '/bus_short_active'], ...
        'Operator', 'AND', 'Position', [385 20 420 50]);
    add_block('simulink/Logic and Bit Operations/Logical Operator', [path '/pos_ground_active'], ...
        'Operator', 'AND', 'Position', [385 60 420 90]);
    add_block('simulink/Logic and Bit Operations/Logical Operator', [path '/neg_ground_active'], ...
        'Operator', 'AND', 'Position', [385 100 420 130]);

    add_block('simulink/Math Operations/Gain', [path '/Inv_Rfault'], ...
        'Gain', '24', 'Position', [455 155 505 185]);
    add_block('simulink/Math Operations/Product', [path '/Fault_Current_Product'], ...
        'Position', [540 140 575 180]);

    add_block('simulink/Ports & Subsystems/Out1', [path '/I_fault_total_Out'], ...
        'Position', [620 155 640 175]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/PosGndActive_Out'], ...
        'Position', [620 75 640 95]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/NegGndActive_Out'], ...
        'Position', [620 115 640 135]);

    add_line(path, 'Clock_In/1', 't_ge_on/1', 'autorouting', 'smart');
    add_line(path, 'Clock_In/1', 't_le_off/1', 'autorouting', 'smart');
    add_line(path, 'Fault_On_Time/1', 't_ge_on/2', 'autorouting', 'smart');
    add_line(path, 'Fault_Off_Time/1', 't_le_off/2', 'autorouting', 'smart');
    add_line(path, 't_ge_on/1', 'fault_window/1', 'autorouting', 'smart');
    add_line(path, 't_le_off/1', 'fault_window/2', 'autorouting', 'smart');

    add_line(path, 'Fault_ID_In/1', 'is_bus_short/1', 'autorouting', 'smart');
    add_line(path, 'Fault_ID_In/1', 'is_pos_ground/1', 'autorouting', 'smart');
    add_line(path, 'Fault_ID_In/1', 'is_neg_ground/1', 'autorouting', 'smart');

    add_line(path, 'fault_window/1', 'bus_short_active/1', 'autorouting', 'smart');
    add_line(path, 'is_bus_short/1', 'bus_short_active/2', 'autorouting', 'smart');
    add_line(path, 'fault_window/1', 'pos_ground_active/1', 'autorouting', 'smart');
    add_line(path, 'is_pos_ground/1', 'pos_ground_active/2', 'autorouting', 'smart');
    add_line(path, 'fault_window/1', 'neg_ground_active/1', 'autorouting', 'smart');
    add_line(path, 'is_neg_ground/1', 'neg_ground_active/2', 'autorouting', 'smart');

    add_line(path, 'Vdc_In/1', 'Inv_Rfault/1', 'autorouting', 'smart');
    add_line(path, 'Inv_Rfault/1', 'Fault_Current_Product/1', 'autorouting', 'smart');
    add_line(path, 'bus_short_active/1', 'Fault_Current_Product/2', 'autorouting', 'smart');

    add_line(path, 'Fault_Current_Product/1', 'I_fault_total_Out/1', 'autorouting', 'smart');
    add_line(path, 'pos_ground_active/1', 'PosGndActive_Out/1', 'autorouting', 'smart');
    add_line(path, 'neg_ground_active/1', 'NegGndActive_Out/1', 'autorouting', 'smart');
end

function create_bus_subsystem(path)
    clear_subsystem(path);

    add_block('simulink/Ports & Subsystems/In1', [path '/I_gen_total_In'], ...
        'Position', [20 45 40 65]);
    add_block('simulink/Ports & Subsystems/In1', [path '/I_load_total_In'], ...
        'Position', [20 95 40 115]);
    add_block('simulink/Ports & Subsystems/In1', [path '/I_fault_total_In'], ...
        'Position', [20 145 40 165]);

    add_block('simulink/Math Operations/Sum', [path '/Inet_Sum'], ...
        'Inputs', '+---+', 'Position', [95 75 120 185]);
    add_block('simulink/Continuous/Transfer Fcn', [path '/Lbus_Dynamics'], ...
        'Numerator', '[1]', 'Denominator', '[Lbus_tau_sim 1]', ...
        'Position', [155 95 240 135]);
    add_block('simulink/Math Operations/Gain', [path '/Inv_Ceq'], ...
        'Gain', '3', 'Position', [270 100 340 130]);
    add_block('simulink/Continuous/Integrator', [path '/Vdc_Integrator'], ...
        'InitialCondition', '1500', 'Position', [370 95 400 125]);
    add_block('simulink/Discontinuities/Saturation', [path '/Vdc_Saturation'], ...
        'UpperLimit', '1550', 'LowerLimit', '200', 'Position', [430 95 500 125]);

    add_block('simulink/Math Operations/Gain', [path '/I_damping'], ...
        'Gain', '0.015', 'Position', [430 145 500 175]);
    add_block('simulink/Sources/Constant', [path '/Vdc_Ref'], ...
        'Value', '1500', 'Position', [250 150 300 170]);
    add_block('simulink/Math Operations/Sum', [path '/Vreg_Error'], ...
        'Inputs', '+-', 'Position', [330 145 350 175]);
    add_block('simulink/Math Operations/Gain', [path '/Kvreg'], ...
        'Gain', '35', 'Position', [370 145 420 175]);

    add_block('simulink/Ports & Subsystems/Out1', [path '/Vdc_Out'], ...
        'Position', [550 100 570 120]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/Idc_Out'], ...
        'Position', [550 40 570 60]);

    add_line(path, 'I_gen_total_In/1', 'Inet_Sum/1', 'autorouting', 'smart');
    add_line(path, 'I_load_total_In/1', 'Inet_Sum/2', 'autorouting', 'smart');
    add_line(path, 'I_fault_total_In/1', 'Inet_Sum/3', 'autorouting', 'smart');
    add_line(path, 'I_damping/1', 'Inet_Sum/4', 'autorouting', 'smart');
    add_line(path, 'Kvreg/1', 'Inet_Sum/5', 'autorouting', 'smart');

    add_line(path, 'Inet_Sum/1', 'Lbus_Dynamics/1', 'autorouting', 'smart');
    add_line(path, 'Lbus_Dynamics/1', 'Inv_Ceq/1', 'autorouting', 'smart');
    add_line(path, 'Inv_Ceq/1', 'Vdc_Integrator/1', 'autorouting', 'smart');
    add_line(path, 'Vdc_Integrator/1', 'Vdc_Saturation/1', 'autorouting', 'smart');

    add_line(path, 'Vdc_Saturation/1', 'I_damping/1', 'autorouting', 'smart');
    add_line(path, 'Vdc_Ref/1', 'Vreg_Error/1', 'autorouting', 'smart');
    add_line(path, 'Vdc_Saturation/1', 'Vreg_Error/2', 'autorouting', 'smart');
    add_line(path, 'Vreg_Error/1', 'Kvreg/1', 'autorouting', 'smart');
    add_line(path, 'Vdc_Saturation/1', 'Vdc_Out/1', 'autorouting', 'smart');
    add_line(path, 'I_load_total_In/1', 'Idc_Out/1', 'autorouting', 'smart');
end

function create_ground_monitor_subsystem(path)
    clear_subsystem(path);

    add_block('simulink/Ports & Subsystems/In1', [path '/Vdc_In'], ...
        'Position', [20 45 40 65]);
    add_block('simulink/Ports & Subsystems/In1', [path '/PosActive_In'], ...
        'Position', [20 105 40 125]);
    add_block('simulink/Ports & Subsystems/In1', [path '/NegActive_In'], ...
        'Position', [20 165 40 185]);

    add_block('simulink/Math Operations/Gain', [path '/Half_Pos'], ...
        'Gain', '0.5', 'Position', [70 30 120 60]);
    add_block('simulink/Math Operations/Gain', [path '/Half_Neg'], ...
        'Gain', '-0.5', 'Position', [70 80 120 110]);
    add_block('simulink/Math Operations/Gain', [path '/Neg_One'], ...
        'Gain', '-1', 'Position', [70 130 120 160]);

    add_block('simulink/Sources/Constant', [path '/Zero'], ...
        'Value', '0', 'Position', [70 190 100 210]);

    add_block('simulink/Signal Routing/Switch', [path '/Vpos_PosSwitch'], ...
        'Criteria', 'u2 >= Threshold', 'Threshold', '0.5', ...
        'Position', [160 30 230 90]);
    add_block('simulink/Signal Routing/Switch', [path '/Vpos_NegSwitch'], ...
        'Criteria', 'u2 >= Threshold', 'Threshold', '0.5', ...
        'Position', [270 30 340 90]);

    add_block('simulink/Signal Routing/Switch', [path '/Vneg_PosSwitch'], ...
        'Criteria', 'u2 >= Threshold', 'Threshold', '0.5', ...
        'Position', [160 110 230 170]);
    add_block('simulink/Signal Routing/Switch', [path '/Vneg_NegSwitch'], ...
        'Criteria', 'u2 >= Threshold', 'Threshold', '0.5', ...
        'Position', [270 110 340 170]);

    add_block('simulink/Ports & Subsystems/Out1', [path '/V_pos_gnd_Out'], ...
        'Position', [390 50 410 70]);
    add_block('simulink/Ports & Subsystems/Out1', [path '/V_neg_gnd_Out'], ...
        'Position', [390 130 410 150]);

    add_line(path, 'Vdc_In/1', 'Half_Pos/1', 'autorouting', 'smart');
    add_line(path, 'Vdc_In/1', 'Half_Neg/1', 'autorouting', 'smart');
    add_line(path, 'Vdc_In/1', 'Neg_One/1', 'autorouting', 'smart');

    add_line(path, 'Zero/1', 'Vpos_PosSwitch/1', 'autorouting', 'smart');
    add_line(path, 'PosActive_In/1', 'Vpos_PosSwitch/2', 'autorouting', 'smart');
    add_line(path, 'Half_Pos/1', 'Vpos_PosSwitch/3', 'autorouting', 'smart');

    add_line(path, 'Vdc_In/1', 'Vpos_NegSwitch/1', 'autorouting', 'smart');
    add_line(path, 'NegActive_In/1', 'Vpos_NegSwitch/2', 'autorouting', 'smart');
    add_line(path, 'Vpos_PosSwitch/1', 'Vpos_NegSwitch/3', 'autorouting', 'smart');

    add_line(path, 'Neg_One/1', 'Vneg_PosSwitch/1', 'autorouting', 'smart');
    add_line(path, 'PosActive_In/1', 'Vneg_PosSwitch/2', 'autorouting', 'smart');
    add_line(path, 'Half_Neg/1', 'Vneg_PosSwitch/3', 'autorouting', 'smart');

    add_line(path, 'Zero/1', 'Vneg_NegSwitch/1', 'autorouting', 'smart');
    add_line(path, 'NegActive_In/1', 'Vneg_NegSwitch/2', 'autorouting', 'smart');
    add_line(path, 'Vneg_PosSwitch/1', 'Vneg_NegSwitch/3', 'autorouting', 'smart');

    add_line(path, 'Vpos_NegSwitch/1', 'V_pos_gnd_Out/1', 'autorouting', 'smart');
    add_line(path, 'Vneg_NegSwitch/1', 'V_neg_gnd_Out/1', 'autorouting', 'smart');
end

function clear_subsystem(path)
    existing_lines = find_system(path, 'FindAll', 'on', 'SearchDepth', 1, 'Type', 'line');
    for i = 1:numel(existing_lines)
        delete_line(existing_lines(i));
    end

    existing = find_system(path, 'SearchDepth', 1, 'Type', 'Block');
    for i = 1:numel(existing)
        if strcmp(existing{i}, path)
            continue;
        end
        delete_block(existing{i});
    end
end
