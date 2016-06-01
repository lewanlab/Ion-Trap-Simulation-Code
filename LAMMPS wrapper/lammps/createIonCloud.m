function [ ionStruct ] = createIonCloud( radius, atomType, number, randomSeed)
%CREATEIONS Creates a cloud of ions that may be added to the trap. 
%
% 'number' ions are added of the specified type (defined previously using
% AddAtomType), arranged randomly within the specified radius (m). the
% 'randomSeed' may be specified manually to ensure sequences are
% repeatable, otherwise a new random number is used.
%
% SYNTAX: createIonCloud(radius, atomType, number, randomSeed)
%
% Example:
%   createIonCloud(1e-4, calciumIon, 40)
% See Also: AddAtomType

if nargin < 4
    randomSeed = randi(100000,1);
end

rng(randomSeed);

% Lammps does have a function that can create ions in a cloud like
% configuration; however, it requires a lattice to be declared, and is
% prone to overlapping atoms. As a result, we instead calculate positions
% in matlab and position the atoms ourselves.

x = ones(0,1);
y = x;
z = x;

for i=1:number
    %Select a random length
    d = rand * radius;
    
    %Select a random azimuthal and inclination angle
    a = pi*rand;
    b = 2*pi*rand;
    
    %Add positions to x, y, z;
    x(end+1) = d * sin(a) * cos(b);
    y(end+1) = d * sin(a) * sin(b);
    z(end+1) = d* cos(a);
end

ionStruct = placeAtoms(atomType, x', y', z');
end