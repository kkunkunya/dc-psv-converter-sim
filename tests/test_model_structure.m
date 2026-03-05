% Input: built model file
% Output: validate topology hierarchy and anti-shortcut constraints
% Pos: tests/test_model_structure.m

function test_model_structure()
    this_file = mfilename('fullpath');
    root_dir = fileparts(fileparts(this_file));

    addpath(root_dir);
    addpath(fullfile(root_dir, 'scripts'));

    build_dc_psv_system();
    model_path = fullfile(root_dir, 'models', 'dc_psv_system.slx');
    load_system(model_path);

    must_blocks = {
        'Control_Subsystem',
        'Generation_Subsystem',
        'DC_Bus_Subsystem',
        'Load_Subsystem',
        'Fault_Subsystem',
        'GroundMonitor_Subsystem'
    };

    for i = 1:numel(must_blocks)
        blk = ['dc_psv_system/' must_blocks{i}];
        assert(~isempty(find_system('dc_psv_system', 'SearchDepth', 1, 'Name', must_blocks{i})), ...
            ['missing top block: ' blk]);
    end

    gen_children = find_system('dc_psv_system/Generation_Subsystem', 'SearchDepth', 1, 'Type', 'Block');
    dg_count = 0;
    for i = 1:numel(gen_children)
        [~, n] = fileparts(gen_children{i});
        if startsWith(n, 'DG') && endsWith(n, '_Branch')
            dg_count = dg_count + 1;
        end
    end
    assert(dg_count == 4, 'generation subsystem must contain 4 DG branches');

    load_children = find_system('dc_psv_system/Load_Subsystem', 'SearchDepth', 1, 'Type', 'Block');
    load_branch_count = 0;
    for i = 1:numel(load_children)
        [~, n] = fileparts(load_children{i});
        if endsWith(n, '_Branch')
            load_branch_count = load_branch_count + 1;
        end
    end
    assert(load_branch_count >= 8, 'load subsystem must contain >=8 converter branches');

    mf_blocks = find_system('dc_psv_system', 'LookUnderMasks', 'all', 'BlockType', 'SubSystem', 'MaskType', 'MATLAB Function');
    assert(isempty(mf_blocks), 'MATLAB Function shortcut is not allowed in rebuilt model');

    all_blocks = find_system('dc_psv_system', 'Type', 'Block');
    assert(numel(all_blocks) - 1 >= 80, 'rebuild model is too small and likely incomplete');

    close_system('dc_psv_system', 0);
end
