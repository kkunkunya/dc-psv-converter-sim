% Input: mode_id, fault_id, stop_time, base_mode_id, case_options
% Output: simulation result struct with electrical states and fault current
% Pos: scripts/run_case_simulation.m

function out = run_case_simulation(mode_id, fault_id, stop_time, base_mode_id, case_options)
    if nargin < 3
        stop_time = 1.0;
    end
    if nargin < 4
        base_mode_id = 1;
    end
    if nargin < 5 || isempty(case_options)
        case_options = struct();
    end

    validateattributes(mode_id, {'numeric'}, {'scalar', 'integer', '>=', 1, '<=', 4});
    validateattributes(base_mode_id, {'numeric'}, {'scalar', 'integer', '>=', 1, '<=', 4});
    validateattributes(fault_id, {'numeric'}, {'scalar', 'integer', '>=', 0, '<=', 3});
    validateattributes(stop_time, {'numeric'}, {'scalar', 'positive'});
    assert(isstruct(case_options), 'case_options must be a struct.');
    with_inductor = true;
    if isfield(case_options, 'with_inductor')
        with_inductor = logical(case_options.with_inductor);
    end
    assert(isscalar(with_inductor), 'with_inductor must be a scalar logical flag.');

    root_dir = fileparts(fileparts(mfilename('fullpath')));
    addpath(root_dir);
    addpath(fullfile(root_dir, 'utils'));
    addpath(fullfile(root_dir, 'scripts'));

    params = init_params();
    inductor_cfg = resolve_inductor_cfg(params, with_inductor);
    refs = set_operating_mode(mode_id, params.Vdc_nominal);
    fault_cfg = set_fault_mode(fault_id);

    assignin('base', 'mode_id_sim', mode_id);
    assignin('base', 'mode_base_sim', base_mode_id);
    assignin('base', 'fault_id_sim', fault_id);
    assignin('base', 'with_inductor_sim', double(with_inductor));
    assignin('base', 'Lrect_tau_sim', inductor_cfg.l_rect_tau);
    assignin('base', 'Lbus_tau_sim', inductor_cfg.l_bus_tau);

    model_path = fullfile(root_dir, 'models', 'dc_psv_system.slx');
    builder_path = fullfile(root_dir, 'scripts', 'build_dc_psv_system.m');
    if ~isfile(model_path)
        build_dc_psv_system();
    else
        model_info = dir(model_path);
        builder_info = dir(builder_path);
        if ~isempty(builder_info) && model_info.datenum < builder_info.datenum
            build_dc_psv_system();
        end
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
    [~, i_gen] = extract_series(simOut.get('I_gen_total'));
    [~, i_load] = extract_series(simOut.get('I_load_total'));
    [~, i_fault] = extract_series(simOut.get('I_fault_total'));

    out = struct();
    out.mode_id = mode_id;
    out.base_mode_id = base_mode_id;
    out.fault_id = fault_id;
    out.with_inductor = with_inductor;
    out.inductor_cfg = inductor_cfg;
    out.refs = refs;
    out.fault_cfg = fault_cfg;
    out.t = t;
    out.Vdc = vdc;
    out.Idc = idc;
    out.V_pos_gnd = v_pos;
    out.V_neg_gnd = v_neg;
    out.I_gen_total = i_gen;
    out.I_load_total = i_load;
    out.I_fault_total = i_fault;

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

function cfg = resolve_inductor_cfg(params, with_inductor)
    cfg = struct();
    if with_inductor
        cfg.l_rect_tau = params.l_rect_tau_with;
        cfg.l_bus_tau = params.l_bus_tau_with;
        return;
    end

    cfg.l_rect_tau = params.l_rect_tau_without;
    cfg.l_bus_tau = params.l_bus_tau_without;
end
