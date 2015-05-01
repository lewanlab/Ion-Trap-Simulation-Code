classdef LAMMPSFix < PrioritisedCfgObject
    %FIX All fixes
    
    properties
        time %apply a limiting timestep if time != 0;
    end
    
    methods
        %Create a fix object, assigning it an unused ID.
        function obj = LAMMPSFix()
            obj.time = 0;
            obj.ID = getUnusedID('fix');
        end
    end
end
