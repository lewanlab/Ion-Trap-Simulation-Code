function [fix] = velocity_squared_damping(gamma, group)
fix = LAMMPSFix();
fix.createInputFileText = @create_input_text;
fix.InputFileArgs = { gamma, group.ID };

    function text = create_input_text(id, gamma, gid)
        text = {
            '# Adding v^2 damping ';
            sprintf('variable %s_x atom "-%e * mass * vx * vx"', id, gamma);
            sprintf('variable %s_y atom "-%e * mass * vy * vy"', id, gamma);
            sprintf('variable %s_z atom "-%e * mass * vz * vz"', id, gamma);
            sprintf('fix %s %s addforce v_%s_x v_%s_y v_%s_z', id, gid, id, id, id);
            };
    end
end

