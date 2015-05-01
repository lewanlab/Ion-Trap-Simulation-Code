function [ fixObj ] = laserCool( atomType, k )
%LASERCOOL Simulates laser cooling of a particular ion species by damping
%velocity of the ion. k =[kx, ky, kz] defines the strength of the damping
%which is of the form f_i = - k_i * v_i (= v_i / relaxation time)
% See Also: langevinBath

if ~isfield(atomType, 'id') || ~isfield(atomType, 'charge') || ~isfield(atomType, 'mass')
   error('must specify a valid atom species.'); 
end

if length(k) == 1
    repmat(k,1,3);
elseif length(k) ~= 3
   error('k must be a length-3 vector or a single number'); 
end

if any(k < 0)
   error('damping must be greater than zero'); 
end

fixObj = LAMMPSFix();
fixObj.cfgFileHandle = @()laserCoolCfg(fixObj.ID, atomType.id, k(1), k(2), k(3));

end

