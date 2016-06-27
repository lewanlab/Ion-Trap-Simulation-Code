function writeAtoms( sim, fHandle )
%WRITEATOMS Writes information describing the initial atom ensemble to the
%log file

%Write atom insertion commands
fwriteCfg(fHandle, sim.AtomList);

%Definitions for atom types
fprintf(fHandle, '# Atom definitions\n');
fwriteCfg(fHandle, sim.AtomTypes);
fprintf(fHandle, '\n');

end