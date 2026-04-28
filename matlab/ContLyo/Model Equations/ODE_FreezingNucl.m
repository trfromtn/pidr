function outputs = ODE_FreezingNucl(t,y,ip)

% Important parameters and constants
mi = y;  % mass of ice
ms = ip.ms_new;  % solute does not freeze
mw = ip.m0 - mi;  % mass of water 
T = ((ip.Kf/ip.Ms)*(ms/(ip.m0-mi))) + 273.15;  % equilibrium temperature
Tc = cal_T(t,ip.Tc1);
Tu = cal_T(t,ip.Tu1);
K = (-ip.Kf*ms/ip.Ms)*(1/(ip.m0-mi)^2);
Tg = cal_Tg(t,ip.Tg);
Ac = ip.Ac;

% Density change during freezing
Vtot = (ms/ip.rhos) + (mw/ip.rhow) + (mi/ip.rhoi);
Vws = Vtot - (mi/ip.rhoi);
A1 = pi*ip.d*(Vtot/Ac);  % new side area
H1 = Vtot/Ac;  % new height
ratio = 2*H1/ip.d;  % aspect ratio
r = (Vws/(ratio*pi))^(1/3);  % radius
z = H1 - r*ratio;  % thickness

% Recalculate the heat transfer coefficient
hs3 = 1/(1/ip.hs3 + (ip.d/2)*log((ip.d/2)/(r))/ip.ki);
hs2 = 1/(1/ip.hs2 + z/ip.ki);
hrad = ip.Fside1*ip.SB*(Tc+T)*(Tc^2+T^2);
if hrad == 0
    hr = 0;
else
    hr = 1/(1/hrad + (ip.d/2)*log((ip.d/2)/(r))/ip.ki);
end

% Energy balance
q1 = ms*ip.Cps*K + mw*ip.Cpw*K - ip.dHfus; 
q2 = hr*A1*(Tc-T) + hs2*Ac*(Tg-T) + hs3*A1*(Tg-T) + ip.hs1*Ac*(Tu-T);
dmidt = q2/q1;

% Output
outputs = dmidt;

return