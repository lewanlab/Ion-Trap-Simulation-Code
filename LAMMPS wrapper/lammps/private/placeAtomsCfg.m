function [ strings ] = placeAtomsCfg( x, y, z, atomTypeID)
%PLACEATOMSCFG Places single atoms.
% The single atoms are placed at the coordinates specified by [x,y,z]. Each
% atom is of the same atomic species, with charge and mass specified in the
% function.

strings =                       {   '# Placing Individual Atoms....'};
for i=1:length(x)
    strings{end+1} =    sprintf(    'create_atoms %d single %e %e %e units box', atomTypeID, x(i), y(i), z(i));
end

% if exist('fix', 'var') && fix
%    %Group the atoms together 
%    groupID = getUnusedID('group');
%    strings{end+1} = sprintf('group %d id %d', groupID, atomTypeID);
%    strings{end+1} = 
   
   %ridid/small might be better for us simulating a large number of
   %small dipoles
   
   %Need to use this to turn off pair-wise interactions within the rigid
   %body for speed: http://lammps.sandia.gov/doc/neigh_modify.html
   
   %For computational efficiency, you should typically define one fix rigid
   %or fix rigid/small command which includes all the desired rigid bodies.
   %LAMMPS will allow multiple rigid fixes to be defined, but it is more
   %expensive.
   
   %Solution: Add all atoms to group 0 that are to be integrated via nve.
   
   %Lammps has a limit of 32 groups at a time, including all. How to have
   %loads of bodies with fix rigid?
   
   %We can ignore the langevin arguments of the fix rigid, lammps will
   %still apply the fix langevin to the individual atoms.
   
%Each rigid body must have two or more atoms. An atom can belong to at
%most one rigid body. Which atoms are in which bodies can be defined via
%several options.

    %For bodystyle single the entire fix group of atoms is treated as one
    %rigid body. This option is only allowed for fix rigid and its
    %sub-styles.

    %For bodystyle molecule, each set of atoms in the fix group with a
    %different molecule ID is treated as a rigid body. This option is
    %allowed for fix rigid and fix rigid/small, and their sub-styles. Note
    %that atoms with a molecule ID = 0 will be treated as a single rigid
    %body. For a system with atomic solvent (typically this is atoms with
    %molecule ID = 0) surrounding rigid bodies, this may not be what you
    %want. Thus you should be careful to use a fix group that only includes
    %atoms you want to be part of rigid bodies.

    %For bodystyle group, each of the listed groups is treated as a
    %separate rigid body. Only atoms that are also in the fix group are
    %included in each rigid body. This option is only allowed for fix rigid
    %and its sub-styles.
% end

strings{end+1} = '';
end

