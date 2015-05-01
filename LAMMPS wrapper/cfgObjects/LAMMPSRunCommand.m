classdef LAMMPSRunCommand < PrioritisedCfgObject
    %LAMMPSRUNCOMMAND commands like run, minimise, clear.   
    
    methods
        %Create a fix object, assigning it an unused ID.
        function obj = LAMMPSRunCommand()
            obj.ID = getUnusedID('command');
        end
    end
end

