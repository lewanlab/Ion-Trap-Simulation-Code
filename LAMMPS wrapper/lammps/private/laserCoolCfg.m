function [ strings ] = laserCoolCfg(fixID, atomTypeID, kx, ky, kz )
%LASERCOOLCFG Config file excerpt for laser cooling of an atom species.

strings = {'#Define laser cooling for a particular atom species.'};

%create a group for this atom type we can use to apply the fix.
groupID = sprintf('group%d', getUnusedID('group'));
strings{end+1} = sprintf('group %s type %d', groupID, atomTypeID);

%create the fix
strings{end+1} =     sprintf('variable kx%s\t\tequal %e', fixID, kx);
strings{end+1} =     sprintf('variable ky%s\t\tequal %e', fixID, ky);
strings{end+1} =     sprintf('variable kz%s\t\tequal %e', fixID, kz);
strings{end+1} =     sprintf('variable fX%s atom "-v_kx%s * vx"', fixID, fixID);
strings{end+1} =     sprintf('variable fY%s atom "-v_ky%s * vy"', fixID, fixID);
strings{end+1} =     sprintf('variable fZ%s atom "-v_kz%s * vz"', fixID, fixID);
strings{end+1} =     sprintf('fix %s %s addforce v_fX%s v_fY%s v_fZ%s', fixID, groupID, fixID, fixID, fixID);

strings{end+1} =     '';

end

