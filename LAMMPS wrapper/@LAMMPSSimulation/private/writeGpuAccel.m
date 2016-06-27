function writeGpuAccel( sim, fileHandle )
%WRITEGPUACCEL Enables/Disables gpu acceleration in the config file

if ~sim.GPUAccel
    fprintf(fileHandle, '# No GPU acceleration will be enabled. (sim.GPUAccel = false)\n');
else
    fprintf(fileHandle, '# Enabling GPU acceleration via CUDA. (sim.GPUAccel = true)\n');
    fprintf(fHandle, 'package gpu 1\n');
    fprintf(fHandle, 'suffix gpu\n');
end

end

