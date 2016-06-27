function WriteInputFile(sim)
%WRITEINPUTFILE Takes a previously configured simulation object and
%produces an input file that implements the desired simulation in lammps.
% 
% SYNTAX: WriteInputFile(sim)
%
% Example:
%  WriteInputFile(sim)

fHandle = fopen(sim.ConfigFileName, 'w');
oc = onCleanup(@() fclose(fHandle));

% Write boiler plate text to the input file:
writeBoilerplate(fHandle);

% Determine gpu acceleration state
writeGpuAccel(sim, fHandle);

% Configure neighbor list generation parameters
writeNeighborList(sim, fHandle);

fprintf(fHandle, 'units si\n');
fprintf(fHandle, 'atom_style charge\n');

fwriteCfg(fHandle, defineSimulationBox(sim.SimulationBox.length, sim.SimulationBox.width, sim.SimulationBox.height, length(sim.AtomTypes(:))));

writePairwiseInteraction(sim, fHandle);

% Add atoms to config file
writeAtoms(sim, fHandle);

%Write appropriate timestep.
if sim.LimitingTimestep < sim.TimeStep
    fprintf('Lowering timestep; some fixes specify minimum timestep (eg. RF fields)\n')
    sim.TimeStep = sim.LimitingTimestep;
end

getSteps(sim.TimeStep, 'set');

fprintf(fHandle, 'timestep %e\n', sim.TimeStep);
%update cfg helper timestep
cfghelperTimestep(sim.TimeStep);

writeOutputStreamConfig(fHandle);

%Rigid Body support: If we have a rigid body, we set the group
%'nonRigidBody' that defines the group of all atoms not in rigid bodies to
%be 'all - rigid body group', otherwise just 'all'.
rbGrps = {};
for i=1:length(sim.Fixes)
    fixId = sim.Fixes(i).ID;
    if length(fixId) > 5 && strcmp(fixId(1:5), 'rbody')
        rbGrps{end+1} = ['g' fixId];
        
        % Write rigid body definitions now
        fprintf(fHandle, '#Priority promoted for fix (%s) due to needing group definition\n', sim.Fixes(i).ID);
        fwriteCell(fHandle, sim.Fixes(i).cfgFileHandle());
        sim.Fixes(i).cfgFileHandle = @() ( {''} );
    end
end

% We must add the nve integrator only to atoms not in rigid body groups.
if ~isempty(rbGrps)
    rbs = cellfun(@(x) [x ' '], rbGrps, 'UniformOutput', false);
    nonRigidBody = ['group nonRigidBody subtract all ' [rbs{:}]];
else
    nonRigidBody = 'group nonRigidBody union all';
end
nonRigidBodyNVE = fixNVEIntegrator('nonRigidBody', nonRigidBody);
fwriteCell(fHandle, nonRigidBodyNVE.cfgFileHandle());

%reset id counts.
getUnusedID('reset');

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

getSteps(0,'set');
end