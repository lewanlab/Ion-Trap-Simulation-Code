function indices = GetSpeciesIndices(obj)
%GETSPECIESINDICES Gets the indices for each species of atom in the simulation.

indices = {};
numPerSpecies = [];
for i=1:length(obj.AtomList)
    numPerSpecies(end+1) = obj.AtomList(i).atomNumber;
    indices{end+1} = sum(numPerSpecies(1:end-1))+1:sum(numPerSpecies(:));
end

end