function indices = GetSpeciesIndices(sim)
%GETSPECIESINDICES Returns a cell array. Each element of the array is a
%list of atomic indices of a particular atom type. The array is ordered in
%the same order that atom types are defined using AddAtomType.
%
% SYNTAX: GetSpeciesIndices(sim)
%
% Example:
%  i = GetSpeciesIndices(sim)
%  calcium = i{1};
% See Also: AddAtomType, AddAtoms

indices = {};
numPerSpecies = [];
for i=1:length(sim.AtomList)
    numPerSpecies(end+1) = sim.AtomList(i).atomNumber;
    indices{end+1} = sum(numPerSpecies(1:end-1))+1:sum(numPerSpecies(:));
end

end