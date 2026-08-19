function outputs = ODE_Post1D(t,T,ip)

% Parameters
m = ip.nz2;
dpsi = ip.dpsi;
psi = ip.psi;
alp = ip.alpe;
rho = ip.rhoe;
Cp = ip.Cpe;
k = ip.ke;
H = ip.H2;
S = ip.S0;
Nw = 0;
dHsub = ip.dHsub;
hb = ip.hb2;
Fside = ip.Fside2;
Ftop = ip.Ftop2;
A2 = ip.A2;
SB = ip.SB;
Vf = ip.Ac*(H-S);

% Shelf/wall temperatures
Tb = cal_T(t,ip.Tb2);
Tu = cal_T(t,ip.Tu2);
Tc = cal_T(t,ip.Tc2);

dSdt = 0;
dTdt = zeros(m,1);  % temperature
for i = 2:m-1
    dTdt(i) = alp*(1/(H-S)^2)*(1/dpsi^2)*(T(i-1)-2*T(i)+T(i+1)) - ((psi(i)-1)*dSdt/(H-S))*(T(i+1)-T(i-1))/(2*dpsi) - Fside*SB*A2*(T(i)^4-Tc^4)/(Vf*rho*Cp);
end
dTdt(1) = alp*(1/(H-S)^2)*(1/dpsi^2)*(2*T(2)-2*T(1)-2*Nw*dpsi*dHsub*(H-S)/k - Ftop*SB*(T(1)^4-Tu^4)*2*dpsi*(H-S)/k)...
        -((psi(1)-1)*dSdt/(H-S))*((H-S)*Nw*dHsub/k + Ftop*SB*(T(1)^4-Tu^4)*(H-S)/k) - Fside*SB*A2*(T(1)^4-Tc^4)/(Vf*rho*Cp);
dTdt(m) = alp*(1/(H-S)^2)*(1/dpsi^2)*(2*T(m-1)-2*T(m)+2*(S-H)*hb*dpsi*(T(m)-Tb)/k)-((psi(m)-1)*dSdt/(H-S))*((S-H)*hb*(T(m)-Tb)/k) - Fside*SB*A2*(T(m)^4-Tc^4)/(Vf*rho*Cp);

outputs = dTdt;

end