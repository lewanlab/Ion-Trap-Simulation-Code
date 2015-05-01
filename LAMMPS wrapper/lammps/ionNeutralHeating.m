function [ fix ] = ionNeutralHeating( atomType, heatingRate )
%IONNEUTRALHEATING AVERAGE heating effect due to collision of ions with background
%gas.
% Applies a small velocity kick to atoms each timestep, similar to Zhang et
% al, but using a normal distribution for v rather than a fixed-length
% vector randomly oriented.

if (heatingRate <= 0)
    error('heating rate must be greater than 0');
end

if ~isfield(atomType, 'id') || ~isfield(atomType, 'charge') || ~isfield(atomType, 'mass')
   error('must specify a valid atom species.'); 
end

fix = LAMMPSFix();
fix.cfgFileHandle = @()ionNeutralHeatingCfg(fix.ID, atomType, heatingRate);

end