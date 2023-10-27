% Adds neutral heating to a specific species with rate heatingRate 
function [fix] = NeutralHeating(atomType, heatingRate)
fix = LAMMPSFix();
fix.createInputFileText = @ionNeutralHeatingCfg;
fix.InputFileArgs = { atomType, heatingRate };
