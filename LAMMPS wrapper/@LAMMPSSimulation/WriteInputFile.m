function WriteInputFile(sim)
%WRITEINPUTFILE Takes a previously configured simulation object and
%produces an input file that implements the desired simulation in lammps.
% 
% SYNTAX: WriteInputFile(sim)
%
% Example:
%  WriteInputFile(sim)

fHandle = fopen(sim.ConfigFileName, 'w');

%reset id counts.
getUnusedID('reset');

fwriteCell(fHandle, boilerplate());
%fprintf(fHandle, 'package omp 0\n');
fprintf(fHandle, 'units si\n');
fprintf(fHandle, 'atom_style charge\n');

fwriteCfg(fHandle, defineSimulationBox(sim.SimulationBox.length, sim.SimulationBox.width, sim.SimulationBox.height, length(sim.AtomTypes(:))));

%Write atom insertion commands
fwriteCfg(fHandle, sim.AtomList);

%Definitions for atom types
fprintf(fHandle, '# Atom definitions\n');
fwriteCfg(fHandle, sim.AtomTypes);
fprintf(fHandle, '\n');

%Write appropriate timestep.
if sim.LimitingTimestep < sim.TimeStep
    fprintf('Lowering timestep; some fixes specify minimum timestep (eg. RF fields)\n')
    sim.TimeStep = sim.LimitingTimestep;
end

getSteps(sim.TimeStep, 'set');

fprintf(fHandle, 'timestep %e\n', sim.TimeStep);
%update cfg helper timestep
cfghelperTimestep(sim.TimeStep);

fprintf(fHandle, 'atom_modify sort 0 1\n');
%Use Coulomb force with 1cm cutoff for now.
fprintf(fHandle, 'pair_style coul/cut %e\npair_coeff * * \n', sim.CoulombCutoff);

fprintf(fHandle, 'thermo 10000\n');
fprintf(fHandle, 'thermo_style custom step cpu\n');
fprintf(fHandle, 'thermo_modify flush yes\n');
fprintf(fHandle, 'fix extra all print 10 "SIMULATION RUNNING----------------------"\n');

%Write fixes and commands in order.
numToWrite = length(sim.Fixes) + length(sim.RunCommands);
fixi = 1;
runi = 1;
for i=1:numToWrite
    %write runs and fixes in the correct order.
    if fixi > length(sim.Fixes)
        %written all fixes - only commands remain
        fwriteCell(fHandle, sim.RunCommands(runi).cfgFileHandle());
        runi = runi + 1;
    elseif runi > length(sim.RunCommands)
        %written all commands, only fixes remain
        fwriteCell(fHandle, sim.Fixes(fixi).cfgFileHandle());
        fixi = fixi + 1;
    else
        
        if sim.Fixes(fixi).Priority < sim.RunCommands(runi).Priority
            fwriteCell(fHandle, sim.Fixes(fixi).cfgFileHandle());
            fixi = fixi + 1;
        else
            fwriteCell(fHandle, sim.RunCommands(runi).cfgFileHandle());
            runi = runi + 1;
        end
    end
end

fclose(fHandle);
getSteps(0,'set');
end