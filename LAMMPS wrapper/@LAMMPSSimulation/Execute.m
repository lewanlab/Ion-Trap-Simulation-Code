function Execute(obj)
%Execute Starts lammps and configures it to perform the simulation.

%write the input file.
WriteInputFile(obj);

%invoke LAMMPS
runLAMMPS(obj.ConfigFileName);

obj.HasExecuted = true;

end