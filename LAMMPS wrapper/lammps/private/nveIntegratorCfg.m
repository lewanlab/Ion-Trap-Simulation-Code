function [ strings ] = nveIntegratorCfg( fixID )
%NVEINTEGRATORCFG Configures all atoms to undergo nve integration.

strings = { '#Configuring integration for all atoms', sprintf('fix %s all nve', fixID), ''};

end

