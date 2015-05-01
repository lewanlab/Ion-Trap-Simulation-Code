function [typeStruct] = AddAtomType( obj, charge, amuMass )
%ADDATOMS Adds atom types.
% Adds types of atoms to the simulation, eg create a definition for barium+
% ions with ex.AddAtomType(1, 138).

if obj.HasExecuted
    warning('Avoid editing the simulation once LAMMPS has executed.');
end

id = length(obj.AtomTypes(:))+1;
typeStruct = struct('cfgFileHandle', @()atomTypesCfg(id, charge, amuMass), 'id', id, 'charge', charge, 'mass', amuMass);
obj.AtomTypes(end+1) = typeStruct;
end
