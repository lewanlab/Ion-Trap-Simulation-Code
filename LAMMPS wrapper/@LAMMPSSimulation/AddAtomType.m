function [typeStruct] = AddAtomType( sim, charge, amuMass )
%ADDATOMS Define atomic species used in simulations. Units are in atomic
%charges and mass units.
%
% SYNTAX: AddAtomType(sim, charge, amuMass)
%
% Example: 
%  AddAtomType(sim, 1, 40) % calcium 40+ ion
% See Also: AddAtoms

if sim.HasExecuted
    warning('Avoid editing the simulation once LAMMPS has executed.');
end

id = length(sim.AtomTypes(:))+1;
typeStruct = struct('cfgFileHandle', @()atomTypesCfg(id, charge, amuMass), 'id', id, 'charge', charge, 'mass', amuMass);
sim.AtomTypes(end+1) = typeStruct;
end
