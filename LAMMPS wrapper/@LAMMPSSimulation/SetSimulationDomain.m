function SetSimulationDomain( obj, length, width, height )
%SETSIMULATIONDOMAIN Sets the size of the simulation 'box'.
obj.SimulationBox = struct('length', length, 'width', width, 'height', height);
end

