% Input: none (uses default 4 mode cases + 3 fault cases)
% Output: data/*.csv, data/*.png, data/summary_results.csv
% Pos: scripts/run_all_cases.m

function run_all_cases()
    root_dir = fileparts(fileparts(mfilename('fullpath')));
    data_dir = fullfile(root_dir, 'data');
    if ~exist(data_dir, 'dir')
        mkdir(data_dir);
    end

    build_dc_psv_system();

    mode_cases = {
        struct('mode', 1, 'fault', 0, 'name', 'mode1_cruise_low'),
        struct('mode', 2, 'fault', 0, 'name', 'mode2_cruise_high'),
        struct('mode', 3, 'fault', 0, 'name', 'mode3_dp_normal'),
        struct('mode', 4, 'fault', 0, 'name', 'mode4_dp_harsh')
    };

    fault_cases = {
        struct('mode', 1, 'fault', 1, 'name', 'fault_bus_short'),
        struct('mode', 1, 'fault', 2, 'name', 'fault_pos_ground'),
        struct('mode', 1, 'fault', 3, 'name', 'fault_neg_ground')
    };

    all_cases = [mode_cases; fault_cases];
    summary_case = cell(numel(all_cases), 1);
    summary_mean = zeros(numel(all_cases), 1);
    summary_std = zeros(numel(all_cases), 1);
    summary_min = zeros(numel(all_cases), 1);
    summary_max = zeros(numel(all_cases), 1);

    for i = 1:numel(all_cases)
        c = all_cases{i};
        out = run_case_simulation(c.mode, c.fault, 1.0);

        csv_path = fullfile(data_dir, [c.name '.csv']);
        png_path = fullfile(data_dir, [c.name '.png']);
        export_case_results(out, csv_path, png_path, c.name);

        summary_case{i} = c.name;
        summary_mean(i) = mean(out.Vdc);
        summary_std(i) = std(out.Vdc);
        summary_min(i) = min(out.Vdc);
        summary_max(i) = max(out.Vdc);
    end

    summary_tbl = table(summary_case, summary_mean, summary_std, summary_min, summary_max, ...
        'VariableNames', {'case', 'vdc_mean', 'vdc_std', 'vdc_min', 'vdc_max'});
    writetable(summary_tbl, fullfile(data_dir, 'summary_results.csv'));
end
