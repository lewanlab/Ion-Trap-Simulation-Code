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

fprintf(fHandle, 'units si\n');
fprintf(fHandle, 'atom_style charge\n\n');

fwriteCfg(fHandle, defineSimulationBox(sim.SimulationBox.length, sim.SimulationBox.width, sim.SimulationBox.height, length(sim.AtomTypes(:))));

% Configure neighbor list generation parameters
writeNeighborList(sim, fHandle);

% Configure pairwise interactions for long-range Coulombics.
writePairwiseInteraction(sim, fHandle);

% Add atoms to config file
writeAtoms(sim, fHandle);

%Write appropriate timestep.
if sim.LimitingTimestep < sim.TimeStep
    fprintf('Lowering timestep; some fixes specify minimum timestep (eg. RF fields)\n')
    sim.TimeStep = sim.LimitingTimestep;
end

% Update timestep on helper utilities and set timestep in input file.
getSteps(sim.TimeStep, 'set');
cfghelperTimestep(sim.TimeStep);
fprintf(fHandle, 'timestep %e\n\n', sim.TimeStep);

% Intermittently write status update to output stream so we know the
% simulation is proceeding as it should.
writeOutputStreamConfig(fHandle);

% Write all defined groups to output file
writeGroups(sim, fHandle)

%Rigid Body support: If we have a rigid body, we set the group
%'nonRigidBody' that defines the group of all atoms not in rigid bodies to
%be 'all - rigid body group', otherwise just 'all'.
rbGrps = {};
for i=1:length(sim.Elements)
    e = sim.Elements{i};
    if (~isa(e, 'LAMMPSFix'))
        continue;
    end
        
    fixId = getID(e);
        
    if length(fixId) > 5 && strcmp(fixId(1:5), 'rbody')
        rbGrps{end+1} = ['g' fixId];
        
        % Write rigid body definitions now
        fprintf(fHandle, '#Priority promoted for fix (%s) due to needing group definition\n', getID(e));
        fwriteCell(fHandle, getLines(e));
        sim.Elements{i} = emptyElement();
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
nonRigidBodyNVE.ID = 'motion';
fwriteCell(fHandle, getLines(nonRigidBodyNVE));

%reset id counts.
%getUnusedID('reset');

% Write each element in the simulation to the input file
for i=1:length(sim.Elements)
    element = sim.Elements{i};
    text = getLines(element);
    fwriteCell(fHandle, text);
end

getSteps(0,'set');
end