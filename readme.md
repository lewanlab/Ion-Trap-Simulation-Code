# LIon
Simulation code was developed using LIon. Documentation and source code are available [here](https://bitbucket.org/footgroup/lion/src/master/) and the publication associated with this software can be found [here](https://arxiv.org/abs/1907.10514). This repository is based in the original LIon repository, but was modified in order to improve accuracy and data handling efficiency. LIon serves as an interface between Matlab and [LAMMPS](https://www.lammps.org/), which is a robust molecular dynamics simulator. LAMMPS has been installed to JILA's computer cluster. In order to run simulations, you must have a cluster account.

# Getting Started
Clone this repository to your cluster home directory. Use the following token as password when prompted *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*. This token will expire in September 2024, once that happens a new token must be generated following these [instructions](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token). In order to run a simulation, you must modify the *RunJob.m* file according to your needs and submit it on the terminal with the command 
```sbatch Job```.
The *RunJob.m* file currently has an example of a simulation input. In order to try this simulation you must define an output folder and filename. 
Simulation outputs will be located at the defined destination folder. If using the cluster, it is recommended you route to your personal 'data' folder as this has much more storage space than your 'user' directory. More information about how to adapt the simulations can be found below. Most scripts and functions are also commented to guide the user while modifying them.


# File structure
The files in the repository are as follows:

* **LAMMPS Wrapper/@LAMMPSSimulation**: Implements the LAMMPSSimulation class, which deals with much of writing simulation config files, managing various fix/atom ids, running the simulation, etc.

* **LAMMPS Wrapper/lammps**: Contains the high-level commands that are used to describe the simulation.

* **Plot**: Useful functions for plotting 3d scatter plots in Matlab with support for color and size dependent from distance from camera.

* **Analysis**: Functions to get the results from the output files of the simulation.

* **Util**: A number of miscellaneous utility methods used for some verifications and examples.

* **Simulation Scripts**: Custom functions to simulate scenarios relevant to the group's research. 

# Simulation Scripts
There are four main simulation scripts 
* `FullSim`: This script runs a simulation of Ca+ ions and a second ion species that are first thermalized to a specific temperature and then are laser cooled. 
* `FullSimCaOnly`: Same as FullSim but for single species Coulomb crystals (Ca+). This was removed due to lack of use, but still exists on the *old* branch.
*  `FullSim_wRawVel`: Same as FullSim but has extra functionality for printing out the micromotion (non-rf-averaged) velocities for each dimension. This was built by Olivia in early 2023 to aid in estimating velocity distributions in preparation for decelerator sims.
* `FullSim_pulse`: Also built by Olivia. It tweaks FullSim to allow for two 100us pulses of a gas of your choice to heat the crystal. Positions are outputted during the second pulse, so you can image what a hot crystal looks like. This was developed to aid with spectroscopy simulations in late 2023. Note that unlike the first three files, this one is designed to intact the endcaps, RF voltage, pulse gas, and pulse pressure (in x factor greater than background, i.e. x*2e-9Torr).

The main scripts can be modified by adding or removing the following functions in order to adapt the simulated scenario
* `NeutralHeating`: this function adds neutral heating to a specific species 
  * `HeatRate`: Calculates the heating rate caused by a specific background gas. It's output is meant to be used as an input for `NeutralHeating`
* `StoLaserCool`: Improved version of the laser cooling model of LIon. More information can be found in Andres' thesis
  `LaserParameters`: Calculates laser cooling damping rate and dopler cooling limit of a single species. It is automatically called by `StoLaserCooled`

# Analysis
Analysis functions take the file name defined in `RunJob.m` as input and read the results from the output files. There are two types of analysis functions and each type has a 2 ion and Ca+ only version. 
* `PlotResults2Ions`: Generates plots of secular temperature, Ca and dark ion energy vs time. Also produces final rms velocity histograms for the axial and radial direction. An extra set of plots can produce raw velocity histograms for the `FullSim_wRawVel` output.
* `Plot3D`: Generates a 3D representation of the simulated crystal.
You must download this entire repository to your computer and run `SetPaths` in order to use these scripts. To read simulation data donwload the *Ener* and *Info* output files and run the script locally to manipulate the plots. 
* `ExpImg`: Generates a simulated experimental image of the crystal. This function requires the positions of the ions to be printed out, which is called with the main script function's last input parameter set to 1. This used to be called directly by `RunJob` but the graphing software no longer exists on the cluster, so most recent practice was to run all analysis offline. The computational cost to do so locally is negligible.

Simulation scripts produce 4 different output text files
* **FinVel**: Final rms velocities of each simulated ion in all 3 dimensions.
* **Ener**: Includes total energy, secular temperature and vrms velocities of the ions. This file is only meant to be read by the functions `PlotResultsCaOnly` or `PlotResults2Ions`. Specific file format can be checked in `FullSim` in case another script were to be developed to use the data differently. 
* **Info**: Contains simulation parameters necessary for some of the analysis functions. These parameters include: Number and mass of each kind of ion, minimization steps, simulation interval and timestep. Specific file format can be checked in `FullSim` in case another script were to be developed to use the data differently. 
* **Positions**: Contains the positions of Ca+ ions during the last 1500 RF cycles in order to generate a simulated experimental image. This file is usually the largest one, so the main scripts will only produce it if their last input is set to 1.
* **RawFinVel**: Raw vector velocities in all 3 dimensions for 10 time steps. Allows numerical modeling of the velocities, particularly important for decelerator reaction sims, where the physical spread in velocities matters.
