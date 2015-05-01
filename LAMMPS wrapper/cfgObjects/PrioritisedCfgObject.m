classdef PrioritisedCfgObject < cfgObject
    %PRIORITISEDCFGOBJECT Cfg objects that are ordered within the input
    %file.
    
    properties (SetAccess=protected)
        ID %ID to use for run commands.
    end
    
    properties
        Priority
    end
    
    methods
        function [obj] = PrioritisedCfgObject()
            obj.Priority = getUnusedID('priority');
        end
    end
end

