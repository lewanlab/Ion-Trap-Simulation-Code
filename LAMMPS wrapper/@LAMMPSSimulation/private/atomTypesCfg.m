function [ strings ] = atomTypesCfg( id, charge, amuMass )
%ATOMTYPESCFG Generates atom type definitions for the LAMMPS input file
strings = { ...
    sprintf('mass %d %e', id, 1.660e-27 * amuMass);
    sprintf('set type %d charge %e', id, 1.6e-19 * charge);
    };
end