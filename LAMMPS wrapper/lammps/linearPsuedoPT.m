function [ fix ] = linearPsuedoPT( OscillatingV, EndcapV, Z0, R0, GeometricConstant, RFFrequency, atomType )
%linearPseudoPT Pseudopotential approximation of a linear paul trap.
% This approximation replaces the radiofrequency electric field of the
% linear Paul trap with a harmonic pseudopotential. This harmonic
% pseudopotential may be approximated via the Mathieu equation (see eg.
% Berkeland's paper, J. App. Phys. 83, (10) 1998).
%
% As the pseudopotential is dependent on the charge:mass ratio of the ion,
% this fix requires that an atomType be supplied. If multiple atom types
% exist in the trap, one fix should be specified for each type. If atomType
% is not specified a cell array of fixes is generated for each atomType.
% 
% See Also: linearPaulTrap, http://tf.nist.gov/general/pdf/1226.pdf

if nargin < 

a_r = -4 * (atomType.charge * 1.6e-19) * GeometricConstant * EndcapV / ...
    ((atomType.mass *  1.660e-27) * Z0^2 * (RFFrequency * 2 * pi)^2);
a_z = - 2 * a_r;

q_r = 2 * (atomType.charge * 1.6e-19) * OscillatingV / ...
    ((atomType.mass *  1.660e-27) * R0^2 * (RFFrequency * 2 * pi)^2);

w_r = (RFFrequency * 2 * pi) / 2 * (a_r + (q_r^2)/2)^0.5;
w_z = (RFFrequency * 2 * pi) / 2 * (a_z)^0.5;

fprintf('Frequency of motion: %e, %e\n', w_r, w_z)

%Spring constants for force calculation.
k_r = w_r ^ 2 * (atomType.mass *  1.660e-27);
k_z = w_z ^ 2 * (atomType.mass *  1.660e-27);

%Time limit for step...
timestep = 1/max(w_z, w_r)/10;

%RFFrequency should be in Hz, not rad per second.
fix = LAMMPSFix();
fix.time = timestep;
fix.cfgFileHandle = @()pseudoLinearPaulTrapCfg(fix.ID, k_r, k_z, atomType.id);

end

