function [ strings ] = langevinBathCfg( fixID, temperature, dampingTime, groupID )
%LANGEVINBATHCFG Creates the cfg file txt for a langevin bath

if nargin < 4
    groupID = 'all';
end

strings = { '#Adding a langevin bath...' };
strings{end+1} = sprintf('fix %s %s langevin %e %e %e 1337', fixID, groupID, temperature, temperature, dampingTime); 
strings{end+1} =  '';

end

