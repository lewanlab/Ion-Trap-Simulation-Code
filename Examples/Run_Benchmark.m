%%
% Runs the benchmark simulation for different atom numbers and records the
% wall time required to complete the simulation.

Numbers = [ 1 3 10 30 100 300 1000 3000 ];
GPUAccel = 1;
results = struct('N', {}, 'time', {});

for NumberOfIons=Numbers
    wallTime = Benchmark(NumberOfIons, GPUAccel);
    results(end+1) = struct('N', NumberOfIons, 'time', wallTime);
end

save('bench.mat', 'Numbers', 'GPUAccel', 'results');