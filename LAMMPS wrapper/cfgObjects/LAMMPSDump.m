classdef LAMMPSDump < LAMMPSRunCommand
    %LAMMPSDUMP dumps, responsible for output to data files.   
    
    methods
        %Create a fix object, assigning it an unused ID.
        function obj = LAMMPSDump()
            obj.ID = getUnusedID('dump');
        end
    end
end
