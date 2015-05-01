function WriteInputFile(obj)
%WRITEINPUTFILE Creates the input file that configures lammps.

fHandle = fopen(obj.ConfigFileName, 'w');

%reset id counts.
getUnusedID('reset');

fwriteCell(fHandle, boilerplate());
fprintf(fHandle, 'units si\n');
fprintf(fHandle, 'atom_style charge\n');



fwriteCfg(fHandle, defineSimulationBox(obj.SimulationBox.length, obj.SimulationBox.width, obj.SimulationBox.height, length(obj.AtomTypes(:))));

%Write atom insertion commands
fwriteCfg(fHandle, obj.AtomList);

%Definitions for atom types
fprintf(fHandle, '# Atom definitions\n');
fwriteCfg(fHandle, obj.AtomTypes);
fprintf(fHandle, '\n');

%Write appropriate timestep.
if obj.LimitingTimestep < obj.TimeStep
    fprintf('Lowering timestep; some fixes specify minimum timestep (eg. RF fields)\n')
    obj.TimeStep = obj.LimitingTimestep;
end

getSteps(obj.TimeStep, 'set');

fprintf(fHandle, 'timestep %e\n', obj.TimeStep);
%update cfg helper timestep
cfghelperTimestep(obj.TimeStep);

fprintf(fHandle, 'atom_modify sort 0 1\n');
%Use Coulomb force with 1cm cutoff for now.
fprintf(fHandle, 'pair_style coul/cut 0.01\npair_coeff * * \n');
%fprintf(fHandle, 'pair_style coul/cut 1e-4\npair_coeff * * \n');

fprintf(fHandle, 'thermo 10000\n');
fprintf(fHandle, 'thermo_style custom step cpu\n');
fprintf(fHandle, 'thermo_modify flush yes\n');
fprintf(fHandle, 'fix extra all print 10 "SIMULATION RUNNING----------------------"\n');

%Write fixes and commands in order.
numToWrite = length(obj.Fixes) + length(obj.RunCommands);
fixi = 1;
runi = 1;
for i=1:numToWrite
    %write runs and fixes in the correct order.
    if fixi > length(obj.Fixes)
        %written all fixes - only commands remain
        fwriteCell(fHandle, obj.RunCommands(runi).cfgFileHandle());
        runi = runi + 1;
    elseif runi > length(obj.RunCommands)
        %written all commands, only fixes remain
        fwriteCell(fHandle, obj.Fixes(fixi).cfgFileHandle());
        fixi = fixi + 1;
    else
        
        if obj.Fixes(fixi).Priority < obj.RunCommands(runi).Priority
            fwriteCell(fHandle, obj.Fixes(fixi).cfgFileHandle());
            fixi = fixi + 1;
        else
            fwriteCell(fHandle, obj.RunCommands(runi).cfgFileHandle());
            runi = runi + 1;
        end
    end
end

fclose(fHandle);
getSteps(0,'set');
end