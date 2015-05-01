function [ dumpCmd ] = dump( filename, lammpsVariables, steps )
%DUMP Dumps variables from lammps into files for analysis.
% LammpsVariables is a cell of lammps variables and/or x,y,z,vx,vy,vz
%
% Example:
%  dump('output.txt', {'id','x','y','z'}, 10);
% See Also: LAMMPSAverage

%Must wait until the config file is generated before we can check multiples
%of steps...

%if any of the lammps variables are fixes, we should add them...

%default value for steps = 1
if nargin < 3
    steps = 1;
end

if isempty(lammpsVariables)
    error('lammpsVariables cannot be empty');
end

%input can be either a single literal, lammps variable, or a cell of either
%of these.
if ~iscell(lammpsVariables) && ~(isa(lammpsVariables, 'LAMMPSVariable') || ischar(lammpsVariables))
    error('lammpsVariables input must either be a string literal, a LAMMPSVariable object or a (mixed) cell array of these.');
end

%convert single property to length 1 cell.
if ~iscell(lammpsVariables)
    lv = cell(1,1);
    lv{1} = lammpsVariables;
    lammpsVariables = lv;
end

%Convert atomic property literals to lammps properties.
lammpsVariables = literalsToLammpsVariables(lammpsVariables);

%If no error thrown, lammpsVariables is now a cell of LAMMPSVariable objects.

dumpCmd = LAMMPSDump();
dumpCmd.cfgFileHandle = @()dumpCfg(filename, getUnusedID('dump'), lammpsVariables, steps);

end
