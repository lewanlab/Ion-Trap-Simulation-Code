function [ strings ] = DoplerHeatingCfg(fixID, atomType, DoplerCoolLimit,CoolingRate )
%IONNEUTRALHEATINGCFG Config file excerpt for ion neutral heating of an atom species.

strings = {'#Define ion-neutral heating for a species..'};

%create a group for this atom type we can use to apply the fix.
groupID = sprintf('group%d', getUnusedID_unused('group'));
strings{end+1} = sprintf('group %s type %d', groupID, atomType.ID);

au=1.6605e-27;
%create the fix
% strings{end+1} =     sprintf('variable k%s equal "sqrt(dt * dt * dt * dt * 2 / %e * %e)"', fixID, atomType.mass*au, heatingRate);
strings{end+1} =     sprintf('variable k%s equal "sqrt(1.38064852e-23 * %e * %e / %e / dt)"', fixID, DoplerCoolLimit, atomType.Mass*au, CoolingRate);
strings{end+1} =     sprintf('variable f%s\t\tatom normal(0,v_k%s,1337)', fixID, fixID);
strings{end+1} =     sprintf('fix %s %s addforce v_f%s v_f%s v_f%s', fixID, groupID, fixID, fixID, fixID);

strings{end+1} =     '';

end

