function AddAtoms( obj, atoms )
%ADDATOMS Adds atoms to the ion trap simulation.
% Add atoms to the simulation. The atoms should be created by an atom
% creation command, eg createIonCloud.
% Syntax: AddAtoms(atoms)
% See Also: CREATEIONCLOUD, PLACEATOMS

if any(~isfield(atoms, {'cfgFileHandle', 'type', 'atomNumber'})) || ~strcmp(atoms.type, 'atom')
    error('Input argument invalid');
end

if obj.HasExecuted
    warning('Avoid editing the simulation once LAMMPS has executed.');
end

obj.AtomList(end+1) = struct('cfgFileHandle', atoms.cfgFileHandle, 'atomNumber', atoms.atomNumber);
end
