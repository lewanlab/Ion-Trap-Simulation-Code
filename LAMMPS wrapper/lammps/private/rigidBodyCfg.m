function [ strings ] = rigidBodyCfg( fixId, varargin )
%RIGIDBODYCFG Input: atom type ids to add to dipole group.

strings =           {'# define a rigid body'};
groupId = ['g' fixId];

if (nargin < 1)
   error('At least one atom type must be specified.');
else
   %create a group for this atom type we can use to apply the fix.
   strings{end+1} = sprintf('group %s type %s', groupId, sprintf('%d ', [varargin{:}]));
end

strings{end+1} = sprintf('fix %s %s rigid single', fixId, groupId);

end