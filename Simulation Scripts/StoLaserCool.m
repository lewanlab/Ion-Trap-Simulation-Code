%This function models laser cooling as a sum of a velocity dependent damping force
%with damping constant B plus a stochastic force due to "solvent atoms" at the 
%doppler cooling limit temperature of the species randomly bumping into the particle.
function [ fixObj ] = StoLaserCool( atomGroup, wavelength,decayrate,amuMass,detuning,rabi)
if ~(exist('detuning','var') && exist('rabi','var'))
    detuning = decayrate/2;
    rabi = decayrate;
end
[B,DopLim] = LaserParameters(wavelength,decayrate,amuMass,detuning,rabi);
fixObj = langevinBath(DopLim,B,atomGroup);