% Input: result struct, csv path, png path, title text
% Output: CSV and optional PNG waveform export
% Pos: scripts/export_case_results.m

function export_case_results(out, csv_path, png_path, fig_title)
    i_gen = get_or_nan(out, 'I_gen_total');
    i_load = get_or_nan(out, 'I_load_total');
    i_fault = get_or_nan(out, 'I_fault_total');
    data_tbl = table(out.t, out.Vdc, out.Idc, i_gen, i_load, i_fault, out.V_pos_gnd, out.V_neg_gnd, ...
        'VariableNames', {'t_s', 'vdc_v', 'idc_a', 'i_gen_a', 'i_load_a', 'i_fault_a', 'v_pos_gnd_v', 'v_neg_gnd_v'});
    writetable(data_tbl, csv_path);

    try
        fig = figure('Visible', 'off');
        tiledlayout(2, 1, 'Padding', 'compact', 'TileSpacing', 'compact');

        nexttile;
        plot(out.t, out.Vdc, 'LineWidth', 1.2);
        grid on;
        ylabel('V_{dc} (V)');
        title(fig_title, 'Interpreter', 'none');

        nexttile;
        plot(out.t, out.Idc, 'LineWidth', 1.0, 'DisplayName', 'I_{dc}');
        hold on;
        if any(isfinite(i_fault))
            plot(out.t, i_fault, 'LineWidth', 1.0, 'DisplayName', 'I_{fault}');
            legend('Location', 'best');
        end
        grid on;
        xlabel('Time (s)');
        ylabel('Current (A)');
        exportgraphics(fig, png_path);
        close(fig);
    catch
        % Batch or headless environments may fail to render; CSV is still exported.
    end
end

function y = get_or_nan(out, field_name)
    if isfield(out, field_name)
        y = out.(field_name);
    else
        y = nan(size(out.t));
    end
end
