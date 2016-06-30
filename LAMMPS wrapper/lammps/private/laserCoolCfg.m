function [ strings ] = laserCoolCfg(fixID, groupID, gamma )
%LASERCOOLCFG Config file excerpt for laser cooling of an atom species.

strings = {'#Define laser cooling for a particular atom species.'};

%create the fix
strings{end+1} =     sprintf('variable %s_gammaX\t\tequal %e', fixID, gamma(1));
strings{end+1} =     sprintf('variable %s_gammaY\t\tequal %e', fixID, gamma(2));
strings{end+1} =     sprintf('variable %s_gammaZ\t\tequal %e', fixID, gamma(3));
strings{end+1} =     sprintf('variable %s_fX atom "-v_%s_gammaX * mass * vx"', fixID, fixID);
strings{end+1} =     sprintf('variable %s_fY atom "-v_%s_gammaY * mass * vy"', fixID, fixID);
strings{end+1} =     sprintf('variable %s_fZ atom "-v_%s_gammaZ * mass * vz"', fixID, fixID);
strings{end+1} =     sprintf('fix %s %s addforce v_%s_fX v_%s_fY v_%s_fZ', fixID, groupID, fixID, fixID, fixID);

strings{end+1} =     '';

end

