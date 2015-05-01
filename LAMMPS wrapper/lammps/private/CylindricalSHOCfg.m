function [ strings ] = CylindricalSHOCfg(fixID, k_r, k_z, groupID )
%LINEARPAULTRAPCFG Config file for atoms attached to the origin by springs,
%cylindrical symmetry. GroupID should be a string, or leave blank for 'all'

strings =           {'#SHO with cylindrical symmetry'};

if (nargin < 4)
    groupID = 'all'; %Fix for all atoms if no atomType is specified.
end

if k_r < 0 || k_z < 0
    warning('One or more spring constants are less than zero (repulsive)');
end

strings{end+1} =     sprintf('variable k_r%s\t\tequal %e', fixID, k_r);
strings{end+1} =     sprintf('variable k_z%s\t\tequal %e', fixID, k_z);
strings{end+1} =     sprintf('variable fX%s atom "-v_k_r%s * x"', fixID, fixID);
strings{end+1} =     sprintf('variable fY%s atom "-v_k_r%s * y"', fixID, fixID);
strings{end+1} =     sprintf('variable fZ%s atom "-v_k_z%s * z"', fixID, fixID);
strings{end+1} =	 sprintf('variable E%s atom "v_k_r%s * (x * x + y * y) / 2 + v_k_z%s * z * z / 2"', fixID, fixID, fixID);
strings{end+1} =     sprintf('fix %s %s addforce v_fX%s v_fY%s v_fZ%s energy v_E%s', fixID, groupID, fixID, fixID, fixID, fixID);
strings{end+1} = '';
end

