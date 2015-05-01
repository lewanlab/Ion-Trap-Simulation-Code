function [ fix ] = twoFreqPseudopot( vA, vB, Vec, Z0, R0, geomC, fA, fB, atomType )
%EFIELDLINEARPAULTRAP Generates a pseudopotential for the ion species
%affected by both components of electric field. For the other, eg the light
%ions, use standard pseudopot.
% http://arxiv.org/pdf/1310.6294v1.pdf

%First frequency component:
a_rA = -4 * (atomType.charge * 1.6e-19) * geomC * Vec / ...
    ((atomType.mass *  1.660e-27) * Z0^2 * (fA * 2 * pi)^2);
a_zA = - 2 * a_rA;
q_rA = 2 * (atomType.charge * 1.6e-19) * vA / ...
    ((atomType.mass *  1.660e-27) * R0^2 * (fA * 2 * pi)^2);

w_rA = (fA * 2 * pi) / 2 * (a_rA + (q_rA^2)/2)^0.5;

w_zA = (fA * 2 * pi) / 2 * (a_zA)^0.5;

%Spring constants for force calculation.
k_rA = w_rA ^ 2 * (atomType.mass *  1.660e-27);
k_zA = w_zA ^ 2 * (atomType.mass *  1.660e-27);

%Second frequency component:
a_rB = -4 * (atomType.charge * 1.6e-19) * geomC * Vec / ...
    ((atomType.mass *  1.660e-27) * Z0^2 * (fB * 2 * pi)^2);
a_zB = - 2 * a_rB;
q_rB = 2 * (atomType.charge * 1.6e-19) * vB / ...
    ((atomType.mass *  1.660e-27) * R0^2 * (fB * 2 * pi)^2);

w_rB = (fB * 2 * pi) / 2 * (a_rB + (q_rB^2)/2)^0.5;

w_zB = (fB * 2 * pi) / 2 * (a_zB)^0.5;

%Spring constants for force calculation.
k_rB = w_rB ^ 2 * (atomType.mass *  1.660e-27);
k_zB = w_zB ^ 2 * (atomType.mass *  1.660e-27);

%Add spring constants together:
k_r = k_rA + k_rB;
k_z = k_zA + k_zB;

%Calculate frequency of motion.
w_r = (k_r / (atomType.mass *  1.660e-27)).^0.5;
w_z = (k_z / (atomType.mass *  1.660e-27)).^0.5;

fprintf('Frequency of motion: %e, %e\n', w_r, w_z)

%Time limit for step...
timestep = 1/max([w_r, w_z])/100;

%RFFrequency should be in Hz, not rad per second.
fix = LAMMPSFix();
fix.time = timestep;
fix.cfgFileHandle = @()pseudoLinearPaulTrapCfg(fix.ID, k_r, k_z, atomType.id);

end

