if isempty(strfind(path,'LAMMPS wrapper'))
   addpath(genpath(sprintf('%s/LAMMPS wrapper', cd)))
    addpath(genpath(sprintf('%s/Analysis', cd)))
    addpath(genpath(sprintf('%s/DCDplotting', cd)))
    addpath(genpath(sprintf('%s/Tools', cd)))
    addpath(genpath(sprintf('%s/Util', cd)))
    addpath(genpath(sprintf('%s/Plot', cd)))
    addpath(genpath(sprintf('%s/Simulation Scripts', cd)))
end
