% Input: none (uses default 4 mode cases + 3 fault cases)
% Output: data/*.csv, data/*.png, data/summary_results.csv
% Pos: scripts/run_all_cases.m

function run_all_cases()
    root_dir = fileparts(fileparts(mfilename('fullpath')));
    data_dir = fullfile(root_dir, 'data');
    if ~exist(data_dir, 'dir')
        mkdir(data_dir);
    end

    params = init_params();
    build_dc_psv_system();

    mode_cases = {
        struct('mode', 1, 'fault', 0, 'name', 'mode1_cruise_low', 'with_inductor', true),
        struct('mode', 2, 'fault', 0, 'name', 'mode2_cruise_high', 'with_inductor', true),
        struct('mode', 3, 'fault', 0, 'name', 'mode3_dp_normal', 'with_inductor', true),
        struct('mode', 4, 'fault', 0, 'name', 'mode4_dp_harsh', 'with_inductor', true)
    };

    fault_cases = {
        struct('mode', 1, 'fault', 1, 'name', 'fault_bus_short', 'with_inductor', true),
        struct('mode', 1, 'fault', 2, 'name', 'fault_pos_ground', 'with_inductor', true),
        struct('mode', 1, 'fault', 3, 'name', 'fault_neg_ground', 'with_inductor', true)
    };

    m53_cases = {
        struct('mode', 1, 'fault', 1, 'name', 'fault_bus_short_with_inductor', 'with_inductor', true),
        struct('mode', 1, 'fault', 1, 'name', 'fault_bus_short_without_inductor', 'with_inductor', false)
    };

    all_cases = [mode_cases; fault_cases; m53_cases];
    summary_case = cell(numel(all_cases), 1);
    summary_with_inductor = zeros(numel(all_cases), 1);
    summary_mean = zeros(numel(all_cases), 1);
    summary_std = zeros(numel(all_cases), 1);
    summary_min = zeros(numel(all_cases), 1);
    summary_max = zeros(numel(all_cases), 1);
    summary_fault_peak = nan(numel(all_cases), 1);
    summary_didt_peak = nan(numel(all_cases), 1);

    for i = 1:numel(all_cases)
        c = all_cases{i};
        out = run_case_simulation(c.mode, c.fault, params.stop_time, 1, ...
            struct('with_inductor', c.with_inductor));

        csv_path = fullfile(data_dir, [c.name '.csv']);
        png_path = fullfile(data_dir, [c.name '.png']);
        export_case_results(out, csv_path, png_path, c.name);

        summary_case{i} = c.name;
        summary_with_inductor(i) = double(c.with_inductor);
        summary_mean(i) = mean(out.Vdc);
        summary_std(i) = std(out.Vdc);
        summary_min(i) = min(out.Vdc);
        summary_max(i) = max(out.Vdc);
        if c.fault == 1
            [didt_peak, ifault_peak] = compute_fault_metrics(out.t, out.I_fault_total, ...
                params.fault_trigger_time, params.fault_trigger_time + params.fault_duration);
            summary_fault_peak(i) = ifault_peak;
            summary_didt_peak(i) = didt_peak;
        end
    end

    summary_tbl = table(summary_case, summary_with_inductor, summary_mean, summary_std, ...
        summary_min, summary_max, summary_fault_peak, summary_didt_peak, ...
        'VariableNames', {'case', 'with_inductor', 'vdc_mean', 'vdc_std', ...
        'vdc_min', 'vdc_max', 'fault_peak_current_a', 'fault_didt_max_a_per_s'});
    writetable(summary_tbl, fullfile(data_dir, 'summary_results.csv'));
end

function [didt_peak, i_peak] = compute_fault_metrics(t, current, t_start, t_end)
    idx = t >= t_start & t <= t_end;
    t_window = t(idx);
    i_window = current(idx);
    if numel(t_window) < 3
        didt_peak = nan;
        i_peak = nan;
        return;
    end

    didt = diff(i_window) ./ diff(t_window);
    didt_peak = max(didt);
    i_peak = max(i_window);
end
