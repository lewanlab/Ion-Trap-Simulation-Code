function [ fix ] = linearPaulTrap( OscillatingV, EndcapV, Z0, R0, GeometricConstant, RFFrequency, Anisotropy, offset )
%LINEARPAULTRAP Applies an oscillating electric field to atoms. The
%characterisation of the trap follows Berkeland et al. (1998).
% RFFrequency should be in Hz, not radians per second. Z0 and R0 are
% the axial and radial dimensions of the trap. The optional parameter
% Anisotropy is used to imbalance fields in X and Y directions, such that
% V_y = anisotropy * V_x
%
% This method produces a simulation using the full radiofrequency electric
% fields - pseudopotential approximations may be more appropriate for most
% cases.
%
% OscillatingV and RFFrequency may be specified as vectors, in which case a
% multi-frequency paul trap is created.
%
% Example:
%  linearPaulTrap(OscV, endV, z0, r0, geomC, RFFreq, Anisotropy, offset)
%  linearPaulTrap(a, q, ions, , geomC, RFFreq, Anisotropy, offset)
% See Also: LinearSecularPaulTrap, http://tf.nist.gov/general/pdf/1226.pdf

if nargin < 8
    offset = [0 0]';
elseif length(offset) ~= 2
    error('Offset must a 2d vector');
end

if nargin < 7
    Anisotropy = 1;
end

if length(OscillatingV) ~= max(size(OscillatingV))
    error('OscillatingV must be a vector or scalar.');
end

if length(RFFrequency) ~= max(size(RFFrequency))
    error('RFFrequency must be a vector or scalar.');
end

RFFrequency = RFFrequency(:);
OscillatingV = OscillatingV(:);

fix = LAMMPSFix();
fix.time = 1/max(RFFrequency(:))/20;
fix.cfgFileHandle = @()linearPaulTrapCfg(fix.ID, OscillatingV, EndcapV, Z0, R0, GeometricConstant, RFFrequency, Anisotropy, offset);

end