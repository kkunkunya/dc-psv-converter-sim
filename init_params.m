% Input: none (optional override via base workspace variables)
% Output: parameter struct and base-workspace defaults for simulation
% Pos: project root/init_params.m

function params = init_params()
    params = struct();

    params.Vdc_nominal = 1500;
    params.sample_time = 5e-5;
    params.stop_time = 1.0;

    % Mode power map in kW: [MP1 MP2 TT1 TT2 RT HOTEL_HIGH HOTEL_LOW ESS]
    params.mode_power_kw = [
        1000 1000   0   0   0 1000 270   0;   % WC1
        2500 2500   0   0   0 1000 270   0;   % WC2
           0    0 300 300 300 1000 270   0;   % WC3
           0    0 800 800 800 1000 270 -50    % WC4 (ESS discharge)
    ];

    params.fault_trigger_time = 0.6;
    params.fault_duration = 0.05;

    assignin('base', 'sim_params', params);
    assignin('base', 'Vdc_nominal', params.Vdc_nominal);
    assignin('base', 'Ts', params.sample_time);

    % Default startup state if user did not set case variables.
    if evalin('base', 'exist(''mode_id_sim'', ''var'')') == 0
        assignin('base', 'mode_id_sim', 1);
    end
    if evalin('base', 'exist(''mode_base_sim'', ''var'')') == 0
        assignin('base', 'mode_base_sim', 1);
    end
    if evalin('base', 'exist(''fault_id_sim'', ''var'')') == 0
        assignin('base', 'fault_id_sim', 0);
    end
end
