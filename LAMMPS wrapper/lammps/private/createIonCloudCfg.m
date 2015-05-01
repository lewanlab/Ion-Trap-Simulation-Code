function [ strings ] = createIonCloudCfg( radius, atomTypeID, number, spacing, randomSeed )
%CREATEIONCLOUDCFG Writes the config file to create a cloud of ions.

%get required ids.
regionID = getUnusedID('region');

strings =           {'# Creating Ion Cloud....'};
strings{end+1} =    sprintf('lattice fcc %f', spacing);
strings{end+1} =    sprintf('region %d sphere 0.0 0.0 0.0 %.8f', regionID, radius);
strings{end+1} =    sprintf('create_atoms %d random %d %d %d', atomTypeID, number, randomSeed, regionID);
strings{end+1} = '';
end

