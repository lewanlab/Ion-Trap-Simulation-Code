# LIon: A package for simulating trapped ion trajectories.

LIon enables a user to author molecular dynamics simulations of ions in electrodynamic traps.
The simulations themselves are performed in [LAMMPS](https://lammps.sandia.gov/), an established and feature-rich code.

# Features 
* LIon's output is verified by comparison to theory through a number of simulations (see Verification folder).
* Multiple ion species
* Pseudopotential approximation
* GPU accelerated force calculation (useful for large numbers of particles).
* Use multiple trap driving frequencies, see [Phys. Rev. A 94, 02360](https://journals.aps.org/pra/abstract/10.1103/PhysRevA.94.023609) for details.
* Define rigid bodies from groups of ions to simulate larger charged objects and investigate rotational motion.

# Installation

First install `LAMMPS` using your preferred method.
Pre-built binaries are available from the `LAMMPS` website [here](https://lammps.sandia.gov/download.html).

If compiling from source make sure the `rigid` and `misc` packages are included in the build. There is good information available on the `LAMMPS` website [here](https://lammps.sandia.gov/doc/Build.html).
Something like the following should work:
```
make yes-rigid
make yes-misc
make serial

# other useful commands
make package # list available packages and help
make ps # list package status
```
This will make the `lmp-serial` executable. You should also include the `gpu` package if you want to use GPU-accelerated styles.

Once you have a `LAMMPS` executable, you must configure LIon to use the executable. In the folder `LAMMPS Wrapper`, create a file called `lammps.cfg` which contains the path to the `LAMMPS` executable you want to use. For example, `C:\lammps\lmp_win_no-mpi.exe`.

To add LIon functions to your Matlab path variable, run the `SetPaths` function. LIon is now ready to use.

This code has been tested to work on Windows with the `LAMMPS-64bit-stable` installation from 2019-06-04.

# Getting Started

A number of examples are available in the Examples folder. These show how to run simulations with one or more ion species, to define the trap parameters, apply cooling to the ions, and define a collection of ions as a rigid body.

# License 

MIT, see `license.txt`.