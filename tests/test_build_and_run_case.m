% Input: model builder + single-case runner
% Output: Ensure model can be built and simulated
% Pos: tests/test_build_and_run_case.m

function test_build_and_run_case()
    this_file = mfilename('fullpath');
    root_dir = fileparts(fileparts(this_file));

    init_params();
    build_dc_psv_system();

    assert(isfile(fullfile(root_dir, 'models', 'dc_psv_system.slx')), 'model file not found');

    out = run_case_simulation(1, 0, 1.0);
    assert(isfield(out, 't') && numel(out.t) > 100, 'time vector missing');
    assert(isfield(out, 'Vdc') && numel(out.Vdc) == numel(out.t), 'Vdc invalid');
    assert(isfield(out, 'Idc') && numel(out.Idc) == numel(out.t), 'Idc invalid');
end
