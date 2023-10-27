% Adds neutral heating to a specific species with rate heatingRate 
function [fix] = NeutralHeating(atomType, heatingRate)
fix = LAMMPSFix();
fix.createInputFileText = @DoplerHeatingCfg;
fix.InputFileArgs = { atomType, heatingRate };
