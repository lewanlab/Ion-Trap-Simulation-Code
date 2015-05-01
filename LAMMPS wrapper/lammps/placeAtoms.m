function [ ionStruct ] = placeAtoms( atomType, x, y, z )
%PLACEATOMS Places the given atomType at the x,y,z coordinates specified,
%which should be column vectors.
% Example:
%  placeAtoms(atomType, x, y, z);

if nargin < 4
    error('not enough input arguments.');
end

%some initial checks on the variables input:
if size(x,2) ~= 1 || size(y,2) ~= 1 || size(z,2) ~= 1
   error('x, y, z must be column vectors.'); 
end

if size(x,1) ~= size(y,1) || size(x,1) ~= size(z,1)
   error('x, y, z must be column vectors of the same length');
end

ionStruct = struct('type', 'atom', 'atomNumber', length(x), 'cfgFileHandle', @()placeAtomsCfg(x,y,z,atomType.id));

end

