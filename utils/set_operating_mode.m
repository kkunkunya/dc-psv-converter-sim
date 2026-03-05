% Input: mode_id (1..4), vdc_nominal
% Output: current references for all load branches (A)
% Pos: utils/set_operating_mode.m

function refs = set_operating_mode(mode_id, vdc_nominal)
    if nargin < 2
        vdc_nominal = 1500;
    end

    validateattributes(mode_id, {'numeric'}, {'scalar', 'integer', '>=', 1, '<=', 4});
    validateattributes(vdc_nominal, {'numeric'}, {'scalar', 'positive'});

    mode_power_kw = [
        1000 1000   0   0   0 1000 270   0;   % WC1
        2500 2500   0   0   0 1000 270   0;   % WC2
           0    0 300 300 300 1000 270   0;   % WC3
           0    0 800 800 800 1000 270 -50    % WC4
    ];

    p = mode_power_kw(mode_id, :) * 1e3; % W

    refs = struct();
    refs.mode_id = mode_id;
    refs.I_mp1_ref = p(1) / vdc_nominal;
    refs.I_mp2_ref = p(2) / vdc_nominal;
    refs.I_tt1_ref = p(3) / vdc_nominal;
    refs.I_tt2_ref = p(4) / vdc_nominal;
    refs.I_rt_ref = p(5) / vdc_nominal;
    refs.I_hotel_high_ref = p(6) / vdc_nominal;
    refs.I_hotel_low_ref = p(7) / vdc_nominal;
    refs.I_ess_ref = p(8) / vdc_nominal;
    refs.total_kw = sum(mode_power_kw(mode_id, :));
end
