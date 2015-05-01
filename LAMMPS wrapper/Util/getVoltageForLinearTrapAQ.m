function [ OscV, Endcap ] = getVoltageForLinearTrapAQ( ionCharge, ionMass, RFFrequency, z0, r0, geometricC, trapAx, trapQx )
%GETVOLTAGEFORLINEARTRAPAQ Calculates the voltage required for given a,q
%operation of the specified trap.

Endcap = trapAx * ionMass * z0^2 * (2*pi*RFFrequency)^2/-(geometricC*4*ionCharge);
OscV = trapQx * -(ionMass * r0^2 * (2*pi*RFFrequency)^2) / (2*ionCharge);

end