% Input: mode_id, Vdc_nominal
% Output: Validate operating-mode current reference mapping
% Pos: tests/test_set_operating_mode.m

function test_set_operating_mode()
    refs = set_operating_mode(1, 1500);

    assert(abs(refs.I_mp1_ref - (1000e3/1500)) < 1e-9, 'Mode1 MP1 current mismatch');
    assert(abs(refs.I_mp2_ref - (1000e3/1500)) < 1e-9, 'Mode1 MP2 current mismatch');
    assert(abs(refs.I_tt1_ref) < 1e-12, 'Mode1 TT1 should be off');

    refs4 = set_operating_mode(4, 1500);
    assert(abs(refs4.I_tt1_ref - (800e3/1500)) < 1e-9, 'Mode4 TT1 current mismatch');
    assert(abs(refs4.I_rt_ref - (800e3/1500)) < 1e-9, 'Mode4 RT current mismatch');
end
