% Input: all test functions under tests/
% Output: non-zero exit on any failure
% Pos: tests/run_all_tests.m

function run_all_tests()
    this_file = mfilename('fullpath');
    root_dir = fileparts(fileparts(this_file));

    addpath(root_dir);
    addpath(fullfile(root_dir, 'tests'));
    addpath(fullfile(root_dir, 'utils'));
    addpath(fullfile(root_dir, 'scripts'));

    tests = {
        @test_set_operating_mode,
        @test_set_fault_mode,
        @test_build_and_run_case,
        @test_acceptance_criteria
    };

    for k = 1:numel(tests)
        feval(tests{k});
    end

    disp('ALL_TESTS_PASSED');
end
