# LIon
Simulation code was developed using LIon. Documentation and source code are available [here](bitbucket.org/footgroup/lion.git) and the publication associated with this software can be found [here](https://arxiv.org/abs/1907.10514). The original LIon repository was modified in order to improve accuracy and data handling efficiency. LIon serves as an interface between Matlab and [LAMMPS](https://www.lammps.org/), which is a robust molecular dynamics simulator. LAMMPS has been installed to JILA's computer cluster. In order to run simulations, you must have a cluster account.

# Getting Started
Clone this repository to your cluster folder. In order to run a simulation, you must modify the *RunJob.m* file according to your needs and submit it on the terminal with the command 
```sbatch Job```.
The *RunJob.m* file currently has an example of a simulation with 100 Ca+ ions and 50 ions of mass 35amu. In order to try this simulation you must define an output folder and filename. This script should also produce a simulated experimental image.
Simulation outputs will be located at the defined destination folder. Information regarding the available functions and their parameters can be found in the documentation file in this repository. Most functions are also commented to guide the user.


# File structure
The files in the repository are as follows:

* `LAMMPS Wrapper/@LAMMPSSimulation`: Implements the LAMMPSSimulation class, which deals with much of writing simulation config files, managing various fix/atom ids, running the simulation, etc.

* `LAMMPS Wrapper/lammps`: Contains the high-level commands that are used to describe the simulation.

* `Plot`: Useful functions for plotting 3d scatter plots in Matlab with support for color and size dependent from distance from camera.

* `Analysis`: Functions to read dump files of atomic trajectories that are output by LAMMPS.

* `Util`: A number of miscellaneous utility methods used for some verifications and examples.

* `Propio`: Custom functions to simulate scenarios relevant to the group's research 

