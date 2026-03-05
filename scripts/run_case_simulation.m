% Input: mode_id, fault_id, stop_time
% Output: simulation result struct (t, Vdc, Idc, V_pos_gnd, V_neg_gnd)
% Pos: scripts/run_case_simulation.m

function out = run_case_simulation(mode_id, fault_id, stop_time)
    if nargin < 3
        stop_time = 1.0;
    end

    root_dir = fileparts(fileparts(mfilename('fullpath')));
    addpath(root_dir);
    addpath(fullfile(root_dir, 'utils'));
    addpath(fullfile(root_dir, 'scripts'));

    params = init_params();
    refs = set_operating_mode(mode_id, params.Vdc_nominal);
    fault_cfg = set_fault_mode(fault_id);

    assignin('base', 'mode_id_sim', mode_id);
    assignin('base', 'fault_id_sim', fault_id);

    model_path = fullfile(root_dir, 'models', 'dc_psv_system.slx');
    if ~isfile(model_path)
        build_dc_psv_system();
    end

    load_system(model_path);
    set_param('dc_psv_system', 'StopTime', num2str(stop_time));
    set_param('dc_psv_system', 'Solver', 'ode4');
    set_param('dc_psv_system', 'FixedStep', num2str(params.sample_time));

    simOut = sim('dc_psv_system', 'ReturnWorkspaceOutputs', 'on');

    [t, vdc] = extract_series(simOut.get('Vdc'));
    [~, idc] = extract_series(simOut.get('Idc'));
    [~, v_pos] = extract_series(simOut.get('V_pos_gnd'));
    [~, v_neg] = extract_series(simOut.get('V_neg_gnd'));

    out = struct();
    out.mode_id = mode_id;
    out.fault_id = fault_id;
    out.refs = refs;
    out.fault_cfg = fault_cfg;
    out.t = t;
    out.Vdc = vdc;
    out.Idc = idc;
    out.V_pos_gnd = v_pos;
    out.V_neg_gnd = v_neg;

    close_system('dc_psv_system', 0);
end

function [t, y] = extract_series(sig)
    if isa(sig, 'timeseries')
        t = sig.Time(:);
        y = sig.Data(:);
        return;
    end

    if isnumeric(sig) && size(sig, 2) >= 2
        t = sig(:, 1);
        y = sig(:, 2);
        return;
    end

    error('Unsupported signal format in simulation output.');
end
