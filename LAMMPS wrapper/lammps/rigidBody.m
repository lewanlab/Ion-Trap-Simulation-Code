function [ fix ] = rigidBody( varargin )
%RIGIDBODY Fix given atom types as a rigid body
% Fixes the given atom types to evolve as a single rigid body. The relative
% positions of the atoms are fixed with respect to each other.
%
% SYNTAX: rigidBody( atomTypeA )
%         rigidBody( atomTypeA, atomTypeB, ... )

if nargin < 1
   error( 'Input invalid. Expected a varargin of atom types to fix together.' ) 
end

listTypes = [];
for i=1:nargin
   listTypes(end+1) = varargin{i}.id;
end

fix = LAMMPSFix('rbody');
fix.createInputFileText = @rigidBodyCfg;
fix.InputFileArgs = listTypes;

end