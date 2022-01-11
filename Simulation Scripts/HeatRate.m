
%{
This function calculates a background gas heat rate according to Eq. 8 of https://link.aps.org/doi/10.1103/PhysRevA.76.012719
The rate depends of the trap pressure (set to 2 * 10^-9 torr), the
background gas (He, Benzene, and N are included) and the temperature of both
the trapped ions and the background gas (the first is set to 1K and the
second to 290K). The "mass of the neutral" is calculated as the averge of
the masses of Ca and the Dark ion.

%}
function rate = HeatRate(background_gas,mass_dark_ion,initial_temperature)
amu_to_kg = 1.66054*10^(-27);
if background_gas == 'He'
     polarizability = 0.51725408;
     mn = 4.002602*amu_to_kg;
elseif background_gas == 'Benzene'
     polarizability = 10.33;
     mn = 78*amu_to_kg;
elseif background_gas == 'N'
     polarizability = 1.094;
     mn = 28.01340 *amu_to_kg;
else 
    error('invalid background gas');
end
Na = 6.02214076*10^23;
Kb = 1.38064852*10^(-23);
Trap_Pressure = 266.6447368422*10^(-9);
Tc = initial_temperature; 
Tn = 290;
mc =(40+mass_dark_ion)/2*amu_to_kg;
miu = mn*mc/(mn+mc);
e = 1.60217662*10^(-19);
eo = 8.85418782*10^(-12);
alpha = polarizability*4*pi*eo/10^6;
Nn = Trap_Pressure/Tn/Na/Kb;
rate = 3*2.21*e*Nn/4/eo*sqrt(alpha*miu)*(Tn - Tc)/(mn+mc)*sqrt(Na)*Kb;
end 
 
%{ 
For Schiller example
Na = 6.02214076*10^23;
Kb = 1.38064852*10^(-23);
Trap_Pressure = 10^(-7);
Tc = initial_temperature; 
Tn = 300;
mc =(138)*amu_to_kg;
miu = mn*mc/(mn+mc);
e = 1.60217662*10^(-19);
eo = 8.85418782*10^(-12);
alpha = polarizability*4*pi*eo/10^6;
Nn = Trap_Pressure/Tn/Na/Kb;
rate = 3*2.21*e*Nn/4/eo*sqrt(alpha*miu)*(Tn - Tc)/(mn+mc)*sqrt(Na);
%}
