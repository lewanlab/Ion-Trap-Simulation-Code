function Unfix( obj, fix )
%UNFIX Removes a fix from the experiment, eg to disable a secular
%potential after minimisation.

%NOTE: What this really does is insert a command to lammps to remove the
%fix. The fix does not really get removed from the experiment object as such.

%check input
if ~isa(fix, 'LAMMPSFix')
    error('Input argument invalid; must be of class LAMMPSFix.');
end

%create a fake object and insert into the fix list to unregister the fix at
%the correct moment.
unfix = LAMMPSFix();
unfix.cfgFileHandle = @()unfixCfg(fix.ID);
obj.AddFix(unfix);

end

