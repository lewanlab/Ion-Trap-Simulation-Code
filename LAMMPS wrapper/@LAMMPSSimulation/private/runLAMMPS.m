function [result] = runLAMMPS( inputFileName )
%RUNLAMMPS Runs lammps with the given file as an input argument.
result = false;

c = onCleanup(@() killProc());
    function killProc()
        if exist('process', 'var') && process.isAlive
            disp('Terminating lammps process.');
            process.destroy();
        end
    end

%Whatever error is thrown (or if user terminates), kill the lammps process
%if it has started.

[directoryS,~,~] = fileparts(mfilename('fullpath'));
[directoryS,~,~] = fileparts(directoryS);
[directoryS,~,~] = fileparts(directoryS);

%Try to find Lammps.cfg file in the wrapper folder.
if exist(fullfile(directoryS, 'Lammps.cfg'), 'file')
    fHandle = fopen(fullfile(directoryS, 'Lammps.cfg'), 'r');
    
    line = fgetl(fHandle);
    % WCK - fgets is not what we want, no matter the need for comments.  Breaks on Linux
    % while (line(1) == '#')
        % line=fgets(fHandle);
    % end
    lammpsPath = line;
    disp(sprintf("lammps thinks lmp is at %s !",lammpsPath));
    fclose(fHandle);
    
    %Need to use java invocation - Matlab 'system' commands are synchronous
    %and so we cannot monitor the output in real time using them.
    list = java.util.ArrayList();
    list.add(lammpsPath);
    list.add('-in');
    list.add(inputFileName);
    %     list.add('-np');
    %     list.add(sprintf('%d',getenv('NUMBER_OF_PROCESSORS')));
    pb = java.lang.ProcessBuilder(list);
    process = pb.start();
    %c = onCleanup(@()eval(['try;', 'disp(''Terminating lammps process.'');', 'process.destroy();', 'disp(''Terminating lammps process.'');', 'catch;', 'end;']));
    
    pause(0.3);
    if ~process.isAlive && process.exitValue ~= 0
        error('LAMMPS executable did not run. Please ensure the program will run without errors in a terminal.');
    end
    
    is = process.getInputStream();
    reader = java.io.BufferedReader(java.io.InputStreamReader(is));
    
    while ~reader.ready() && process.isAlive
        pause(0.1);
    end
    line = reader.readLine();
    
    atomCount = 0;
    while line ~= []
        %convert java.lang string to a Matlab one.
        line = char(line);
        
        if length(line) > 5 && strcmp(line(1:5), 'ERROR')
            error('LAMMPS did not run correctly; an error was thrown:\n%s', line);
        end
        
        %Handle special cases - filter out numerous 'created 1 atoms' messages:
        if strcmp('Created 1 atoms',line)
            atomCount = atomCount + 1;
        elseif atomCount > 0
            fprintf('Created %d atoms\n', atomCount)
            atomCount = 0;
        end
        
        if strcmp('Created 0 atoms', line)
            error('lammps created 0 atoms - perhaps you called place atoms with positions outside the simulation box?');
        end
        
        if ~strcmp(line, 'SIMULATION RUNNING----------------------') && atomCount == 0
            fprintf(sprintf('%s\n',line))
        end
        line = reader.readLine();
    end
    
    reader.close();
    process.waitFor();
    result = true;
    
else
    error(['Cannot find Lammps.cfg file. Please make sure this exists'...
        ' within the folder `LAMMPS Wrapper`. This file should be a'...
        ' plain-text file containing the path to the lammps executable'...
        ' that LIon should run (eg C:\lammps\lmp_win_no-mpi.exe)']);
end

end

