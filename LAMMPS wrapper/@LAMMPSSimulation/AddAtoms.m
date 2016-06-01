function AddAtoms( sim, atoms )
%ADDATOMS Adds atoms to the ion trap simulation.
% Add a defined set of atoms to the simulation. The atoms should be defined by an atom
% creation command, for example createIonCloud or placeAtoms
% 
% SYNTAX: AddAtoms(atoms)
% 
% See Also: CREATEIONCLOUD, PLACEATOMS

if any(~isfield(atoms, {'cfgFileHandle', 'type', 'atomNumber'})) || ~strcmp(atoms.type, 'atom')
    error('Input argument invalid');
end

if sim.HasExecuted
    warning('Avoid editing the simulation once LAMMPS has executed.');
end

sim.AtomList(end+1) = struct('cfgFileHandle', atoms.cfgFileHandle, 'atomNumber', atoms.atomNumber);
end
