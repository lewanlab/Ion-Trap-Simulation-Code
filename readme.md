# LIon
Simulation code was developed using LIon. Documentation and source code are available [here](https://bitbucket.org/footgroup/lion/src/master/) and the publication associated with this software can be found [here](https://arxiv.org/abs/1907.10514). This repository is based in the original LIon repository, but was modified in order to improve accuracy and data handling efficiency. LIon serves as an interface between Matlab and [LAMMPS](https://www.lammps.org/), which is a robust molecular dynamics simulator. LAMMPS has been installed to JILA's computer cluster. In order to run simulations, you must have a cluster account.

# Getting Started
Clone this repository to your cluster home directory. Use the following token as password when prompted *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*. This token will expire on Feb 10 of 2022, once that happens a new token must be generated following these [instructions](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). In order to run a simulation, you must modify the *RunJob.m* file according to your needs and submit it on the terminal with the command 
```sbatch Job```.
The *RunJob.m* file currently has an example of a simulation with 100 Ca+ ions and 50 ions of mass 35amu. In order to try this simulation you must define an output folder and filename. This script should also produce a simulated experimental image.
Simulation outputs will be located at the defined destination folder. More information about how to adapt the simulations can be found below. Most scripts and functions are also commented to guide the user while modifying them.


# File structure
The files in the repository are as follows:

* **LAMMPS Wrapper/@LAMMPSSimulation**: Implements the LAMMPSSimulation class, which deals with much of writing simulation config files, managing various fix/atom ids, running the simulation, etc.

* **LAMMPS Wrapper/lammps**: Contains the high-level commands that are used to describe the simulation.

* **Plot**: Useful functions for plotting 3d scatter plots in Matlab with support for color and size dependent from distance from camera.

* **Analysis**: Functions to get the results from the output files of the simulation.

* **Util**: A number of miscellaneous utility methods used for some verifications and examples.

* **Simulation Scripts**: Custom functions to simulate scenarios relevant to the group's research. 

# Simulation Scripts
There are two main simulation scripts 
* `FullSim`: This script runs a simulation of Ca+ ions and a second ion species that are first thermalized to a specific temperature and then are laser cooled. 
* `FullSimCaOnly`: Same as FullSim but for single species Coulomb crystals (Ca+).

The main scripts can be modified by adding or removing the following functions in order to adapt the simulated scenario
* `NeutralHeating`: this function adds neutral heating to a specific species 
  * `HeatRate`: Calculates the heating rate caused by a specific background gas. It's output is meant to be used as an input for `NeutralHeating`
* `StoLaserCool`: Improved version of the laser cooling model of LIon. More information can be found in Andres' thesis
  * LaserParameters: Calculates laser cooling damping rate and dopler cooling limit of a single species. It is automatically called by `StoLaserCooled`

# Analysis
Analysis functions take the file name defined in `RunJob.m` as input and read the results from the output files. There are two types of analysis functions and each type has a 2 ion and Ca+ only version. 
* `PlotResults`: Generates plots of secular temperature, Ca and total energy vs time. Also produces final rms velocity histograms for the axial and radial direction.
* `Plot3D`: Generates a 3D representation of the simulated crystal.
You must download this entire repository to your computer and run `SetPaths` in order to use these scripts. To read simulation data donwload the *Ener* and *Info* output files and run the script locally to manipulate the plots. 
* `ExpImg`: Generates a simulated experimental image of the crystal. This function should be called in `RunJob.m` after any of the main scripts with their last parameter set to 1. The produced jpg file will be located at the output folder. 

Simulation scripts produce 4 different output text files
* **FinVel**: Final rms velocities of each simulated ion in all 3 dimensions.
* **Ener**: Includes total energy, secular temperature and vrms velocities of the ions. This file is only meant to be read by the functions `PlotResultsCaOnly` or `PlotResults2Ions`. Specific file format can be checked in `FullSim` in case another script were to be developed to use the data differently. 
* **Info**: Contains simulation parameters necessary for some of the analysis functions. These parameters include: Number and mass of each kind of ion, minimization steps, simulation interval and timestep. Specific file format can be checked in `FullSim` in case another script were to be developed to use the data differently. 
* **Positions**: Contains the positions of Ca+ ions during the last 1500 RF cycles in order to generate a simulated experimental image. This file is usually the largest one, so the main scripts will only produce it if their last input is set to 1. 
