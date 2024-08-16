%
% Copyright (c) The acados authors.
%
% This file is part of acados.
%
% The 2-Clause BSD License
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.;

%

function render_acados_sim_templates(acados_sim_json_file)

    acados_root_dir = getenv('ACADOS_INSTALL_DIR');
    acados_template_folder = fullfile(acados_root_dir,...
                          'interfaces', 'acados_template', 'acados_template');

    t_renderer_location = get_tera();

    %% load json data
    acados_sim = loadjson(fileread(acados_sim_json_file));
    model_name = acados_sim.model.name;

    %% render templates
    template_dir = fullfile(acados_template_folder, 'c_templates_tera','*');
    matlab_template_dir = fullfile(acados_template_folder, 'c_templates_tera','matlab_templates', '*');
    json_fullfile = fullfile(pwd, acados_sim_json_file);
    main_dir = pwd;
    chdir('c_generated_code');

    % main_sim
    template_file = 'main_sim.in.c';
    out_file = ['main_sim_', model_name, '.c'];
    render_file( json_fullfile, template_dir, template_file, out_file, t_renderer_location )

    % MEX class
    template_file = 'mex_sim_solver.in.m';
    out_file = [ model_name, '_mex_sim_solver.m'];
    render_file( json_fullfile, matlab_template_dir, template_file, out_file, t_renderer_location )

    % method to make mexFunctions
    template_file = 'make_mex_sim.in.m';
    out_file = ['make_mex_sim_', model_name, '.m'];
    render_file( json_fullfile, matlab_template_dir, template_file, out_file, t_renderer_location )

    % MEX constructor
    template_file = 'acados_sim_create.in.c';
    out_file = ['acados_sim_create_', model_name, '.c'];
    render_file( json_fullfile, matlab_template_dir, template_file, out_file, t_renderer_location )

    % MEX destructor
    template_file = 'acados_sim_free.in.c';
    out_file = ['acados_sim_free_', model_name, '.c'];
    render_file( json_fullfile, matlab_template_dir, template_file, out_file, t_renderer_location )

    % MEX set
    template_file = 'acados_sim_set.in.c';
    out_file = ['acados_sim_set_', model_name, '.c'];
    render_file( json_fullfile, matlab_template_dir, template_file, out_file, t_renderer_location )

    % sim_solver
    template_file = 'acados_sim_solver.in.c';
    out_file = ['acados_sim_solver_', model_name, '.c'];
    render_file( json_fullfile, template_dir, template_file, out_file, t_renderer_location )

    template_file = 'acados_sim_solver.in.h';
    out_file = ['acados_sim_solver_', model_name, '.h'];
    render_file( json_fullfile, template_dir, template_file, out_file, t_renderer_location )

    template_file = 'acados_sim_solver_sfun.in.c';
    out_file = ['acados_sim_solver_sfunction_', model_name, '.c'];
    render_file( json_fullfile, matlab_template_dir, template_file, out_file, t_renderer_location )

    template_file = 'make_sfun_sim.in.m';
    out_file = ['make_sfun_sim_', model_name, '.m'];
    render_file( json_fullfile, matlab_template_dir, template_file, out_file, t_renderer_location )

    % headers and custom C-code files
    c_dir = pwd;
    chdir([model_name, '_model']);
    template_file = 'model.in.h';
    out_file = [model_name, '_model.h'];
    render_file( json_fullfile, template_dir, template_file, out_file, t_renderer_location )
    cd(c_dir);

    % Makefile
    template_file = 'Makefile.in';
    out_file = 'Makefile';
    render_file( json_fullfile, template_dir, template_file, out_file, t_renderer_location )

    % CMake
    template_file = 'CMakeLists.in.txt';
    out_file = 'CMakeLists.txt';
    render_file( json_fullfile, template_dir, template_file, out_file, t_renderer_location )

    fprintf('Successfully rendered acados templates!\n');
    cd(main_dir)

end


%% auxilary functions
function render_file( json_fullfile, template_dir, template_file, out_file, ...
                      t_renderer_location )

    os_cmd = [t_renderer_location, ' "',...
        template_dir, '"', ' ', '"', template_file, '"', ' ', '"',...
        json_fullfile, '"', ' ', '"', out_file, '"'];

    [ status, result ] = system(os_cmd);
    if status
        cd ..
        error('rendering %s failed.\n command: %s\n returned status %d, got result:\n%s\n\n',...
            template_file, os_cmd, status, result);
    end
    % NOTE: this should return status != 0, maybe fix in tera renderer?
    if ~isempty(strfind( result, 'Error' )) % contains not implemented in Octave
        cd ..
        error('rendering %s failed.\n command: %s\n returned status %d, got result: %s',...
            template_file, os_cmd, status, result);
    end
end

