%% Two Species in a Linear Paul Trap
% Author: Elliot Bentine.

% This script performs simulations in the spirit of
% OKADA, WADA, TAKAYANAGI, OHTANI, AND SCHUESSLER
% PHYSICAL REVIEW A 81, 013420 (2010)
% http://sibor.physics.tamu.edu/publications/papers/a.pdf

% Define trap parameters
rf = 5.634e6; % Hz
Vo = 252.5; % V
Ve = 5; % V
geomC = 0.3;
r0  = 3.5e-3;
z0  = 10e-3;

% We add 60 Ca ions and a number of NH3+ ions. The Ca is laser cooled to
% 4mK and we observe the sympathetic temperature that the NH3+ is cooled
% to.

NumberNH3 = [ 10 20 30 40 50 ];
NumberCa  = 60;
getFileName = @(x) sprintf('output%d.txt', x);

for num=NumberNH3
    
    sim = LAMMPSSimulation();
    sim.GPUAccel = 0;
    SetSimulationDomain(sim, 1e-3,1e-3,1e-3);
    
    % The two ion species used in this paper are NH3+ and 40Ca+
    NH3 = AddAtomType(sim, 1, 17);
    Ca40 = AddAtomType(sim, 1, 40);
    
    % Create the ion clouds.
    rIC = 1e-3; % place atoms randomly within this radius
    
    cloudNH3 = createIonCloud(sim, rIC, NH3, num);
    cloudCa40 = createIonCloud(sim, rIC, Ca40, NumberCa);
    
    % add the electric field
    sim.Add(linearPT(Vo, Ve, z0, r0, geomC, rf));
    
    % minimise the system using a langevin bath applied to both species
    allBath = langevinBath(0, 100e-6);
    sim.Add(allBath);
    sim.Add(evolve(100000));
    sim.Remove(allBath);
    
    % Apply the langevin bath for one species
    sim.Add(langevinBath(4e-3, 100e-6, sim.Group(Ca40)));
    
    % Perform a time evolution to crystallise the system.
    sim.Add(evolve(10000));
    
    % Having minimised the system, output the coordinates of both species
    % and time averaged velocities from which we can calculate the secular
    % temperature.
    sim.Add(dump(getFileName(num), {'id', 'x', 'y', 'z', timeAvg({'vx', 'vy', 'vz'}, 1/rf)}, 10));
    sim.Add(evolve(1000));
    sim.Execute();
    
end

%%
% Now we post process the simulation results, calculating the temperature
% of each species.

figure(1);
set(gcf, 'Units', 'Normalized', 'Position', [ 0.1 0.1 0.8 0.8 ]);

for i=1:length(NumberNH3)
    num = NumberNH3(i);
    
    [~, id, x,y,z, vx,vy,vz] = readDump(getFileName(num));
    subplot(1, length(NumberNH3), i);
    % Select indices from each one and plot the image of both species.  
    % First select color according to species type
    pastelBlue = [112 146 190]/255;
    pastelRed = [237 28 36]/255;
    color = repmat(pastelRed, size(x, 1), 1);
    color(1:num, :) = repmat(pastelBlue, num, 1);
    
    depthPlot(x(:,end),y(:,end),z(:,end),color, [50 200])

    T = mean((vx(1:num, :).^2+vy(1:num, :).^2+vz(1:num, :).^2)/2 * 1.66e-27 * 17) / 1.38e-23;
    title(['T=' sprintf('%.1f (%.1f) mK', mean(T) * 1e3, std(T) * 1e3)]);
    %axis equal
    view([ 90 0 ]);
end

% calculate secular temperature;
T = mean((vx(1:num, :).^2+vy(1:num, :).^2+vz(1:num, :).^2)/2 * 1.66e-27 * 17) / 1.38e-23;
