function [Modes, eigNM] = getNormalModes(x,y,z,wr, wz,mass, qQ)

au = 1.660538921e-27; % atomic mass units (kg)

N = size(x, 2);
dPos = zeros(3,N);
H = zeros(3*N,3*N);
h = 1e-12;

pos = getCrystalPos(x,y,z);

for i = 1:3*N
    for j = i:3*N
        dPos(i) = h;
        
        H(i,j) = (ijForce(N,pos+dPos,wr,wz,mass,qQ,j)-...
            ijForce(N,pos-dPos,wr,wz,mass,qQ,j))/(2*h);
        
        dPos(i) = 0;
        
        H(j,i) = H(i,j); % hessian is symmetric
    end
end


Mm = diag((au*mass(:)).^(-0.5));
[Modes, eigV] = eig(Mm*H*Mm);
eigNM = diag(sqrt(-eigV')/2/pi);       % return NM freqs in Hz

end

function lPos = getCrystalPos(x, y, z)
%Take first frame, where the ion positions have been minimised in the
%secular potential.
lPos = [x(1,:); y(1,:); z(1,:)];
end

function ijF = ijForce(N,pos,wr, wz, mass,qQ,ind)

qe = 1.602e-19; % electron charge (C)
au = 1.660538921e-27; % atomic mass units (kg)
e0 = 8.85418781762e-12;

% Coulomb interaction

Dx = ones(N,1)*pos(1,:)-pos(1,:)'*ones(1,N);
Dy = ones(N,1)*pos(2,:)-pos(2,:)'*ones(1,N);
Dz = ones(N,1)*pos(3,:)-pos(3,:)'*ones(1,N);

Dr3 = (Dx.^2+Dy.^2+Dz.^2).^(3/2)+eye(N); % eye(N) to avoid division by zero

forceEij = 1./(4*pi*e0*mass)*qe^2/au.*...
    [sum(qQ.*Dx./Dr3); sum(qQ.*Dy./Dr3); sum(Dz./Dr3)];

% CAUTION: force IS ACCELERATION. 
% GETS ME EVERY TIME

% pseudopotential force
force = repmat([wr, wr, wz]',1,N).^2.*pos;

% add E-field +forceEij for repulsion

force = -force+forceEij;
force = mass.*force*au;
ijF = force(ind);

end