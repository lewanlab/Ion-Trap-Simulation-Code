function [ strings ] = linearPaulTrapCfg(fixID, OscillatingV, EndcapV, Z0, R0, GeometricConstant, RFFrequency, Anisotropy, offset )
%LINEARPAULTRAPCFG Writes the config file for a linear paul trap.

strings =           { sprintf('#Creating a Linear Paul Trap... (fixID=%s)', fixID)};
%strings{end+1} =     sprintf('variable trapF%s\t\tequal %e', fixID, RFFrequency*2*pi);
strings{end+1} =     sprintf('variable endCapV%s\t\tequal %e', fixID, EndcapV);
strings{end+1} =     sprintf('variable radius%s\t\tequal %e', fixID, R0);
strings{end+1} =     sprintf('variable zLength%s\t\tequal %e', fixID, Z0);
strings{end+1} =     sprintf('variable geomC%s\t\tequal %e', fixID, GeometricConstant);
strings{end+1} =     '' ;

strings{end+1} =     '#Define frequency components' ;

for i=1:size(OscillatingV,1)
    strings{end+1} =     sprintf('variable oscVx%s%d\t\tequal %e', fixID, i, OscillatingV(i));
    strings{end+1} =     sprintf('variable oscVy%s%d\t\tequal %e', fixID, i, OscillatingV(i) * Anisotropy);
    strings{end+1} =     sprintf('variable phase%s%d\t\tequal "%e * step*dt"', fixID, i, RFFrequency(i)*2*pi);
    
    strings{end+1} =     sprintf('variable oscConstx%s%d\t\tequal "v_oscVx%s%d/(v_radius%s*v_radius%s)"', fixID, i, fixID, i, fixID, fixID);
    strings{end+1} =     sprintf('variable oscConsty%s%d\t\tequal "v_oscVy%s%d/(v_radius%s*v_radius%s)"', fixID, i, fixID, i, fixID, fixID);
end

strings{end+1} =     sprintf('variable statConst%s\t\tequal "v_geomC%s * v_endCapV%s / (v_zLength%s * v_zLength%s)"', fixID, fixID, fixID, fixID, fixID);
strings{end+1} =     '' ;

xC = '';
yC = '';

xPos = sprintf('(x-%e)', offset(1));
yPos = sprintf('(y-%e)', offset(2));

%Simplify this case for 0 displacement so that unneccesary operations are
%not used.
if offset(1) == 0
    xPos = 'x';
end

if offset(2) == 0
    yPos = 'y';
end


for i=1:size(OscillatingV,1)
    %Construct a string referencing the constants for this frequency.
    xC = [xC sprintf('v_oscConstx%s%d * cos(v_phase%s%d) * %s + ', fixID, i, fixID, i, xPos)];
    yC = [yC sprintf('v_oscConsty%s%d * cos(v_phase%s%d) * -%s + ', fixID, i, fixID, i, yPos)];
end


strings{end+1} =     sprintf('variable oscEX%s atom "%s + v_statConst%s * %s"', fixID, xC(1:end-3),fixID, xPos);
strings{end+1} =     sprintf('variable oscEY%s atom "%s + v_statConst%s * %s"', fixID, yC(1:end-3),fixID, yPos);

strings{end+1} =     sprintf('variable statEZ%s atom "v_statConst%s * 2 * -z"', fixID, fixID);

strings{end+1} =     sprintf('fix %s all efield v_oscEX%s v_oscEY%s v_statEZ%s', fixID, fixID,fixID, fixID);
strings{end+1} = '';
end

