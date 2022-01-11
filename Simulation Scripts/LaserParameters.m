% Calculates laser cooling damping rate using Eq 2.25 on Gingell's thesis
function  [B, DopLim] = LaserParameters(wavelength,decayrate,amuMass,detuning,rabi)
DopLim = Const.hbar*decayrate/(Const.kB*2);
k = 2*pi/wavelength;
B = 16*Const.hbar*k^2*decayrate*detuning*rabi^2/(decayrate^2+2*rabi^2+4*detuning^2)^2;
B = B/(amuMass*Const.amu);
%Since the Lan. Bath function uses 1/damping constant, we invert it. And
%since laser cooling is being applied in a single direction, we divide the
%daping constant by 3
B = 3/B;
end 