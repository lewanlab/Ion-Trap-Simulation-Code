classdef cfgObject < matlab.mixin.Heterogeneous & handle
    %CFGOBJECT Objects that implement LAMMPS commands in the input file.    
    properties
        cfgFileHandle % A function that generates text for the lammps input file
    end   
end

