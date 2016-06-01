%[timestep, id, x,y,z] = readDump('positions.txt');
[timestep, id, x,y,z,proc,ex,ey,ez] = readDump('positions-0.txt');
%%
plot(x','.')
legend('index 1', 'index 2', 'index 3')
title('Trajectories of atoms')
xlabel('timesteps')
ylabel('X (m)');