classdef LAMMPSFix < PrioritisedCfgObject
    %FIX All fixes
    
    properties
        time %apply a limiting timestep if time != 0;
    end
    
    methods
        %Create a fix object, assigning it an unused ID.
        function obj = LAMMPSFix(baseName)
            if nargin < 1
                baseName = '';
            end
            obj.time = 0;
            obj.ID = [baseName getUnusedID('fix')];
        end
    end
end
