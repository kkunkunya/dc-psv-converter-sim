% Input: result struct, csv path, png path, title text
% Output: CSV and optional PNG waveform export
% Pos: scripts/export_case_results.m

function export_case_results(out, csv_path, png_path, fig_title)
    data_tbl = table(out.t, out.Vdc, out.Idc, out.V_pos_gnd, out.V_neg_gnd, ...
        'VariableNames', {'t_s', 'vdc_v', 'idc_a', 'v_pos_gnd_v', 'v_neg_gnd_v'});
    writetable(data_tbl, csv_path);

    try
        fig = figure('Visible', 'off');
        plot(out.t, out.Vdc, 'LineWidth', 1.2);
        grid on;
        xlabel('Time (s)');
        ylabel('V_{dc} (V)');
        title(fig_title);
        exportgraphics(fig, png_path);
        close(fig);
    catch
        % Batch or headless environments may fail to render; CSV is still exported.
    end
end
