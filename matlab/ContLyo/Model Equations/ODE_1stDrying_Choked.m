function outputs = ODE_1stDrying_Choked(t,T,ip)

m = ip.nz2;
dpsi = ip.dpsi;
psi = ip.psi;
H = ip.H2;
alp = ip.alpf;
rho = ip.rhof;
Cp = ip.Cpf;
k = ip.kf;
dHsub = ip.dHsub;
hb = ip.hb2;
Fside = ip.Fside2;
Ftop = ip.Ftop2;
A2 = ip.A2;
SB = ip.SB;
Ac = ip.Ac;

% Shelf/wall temperatures
Tb = cal_T(t,ip.Tb2);
Tu = cal_T(t,ip.Tu2);
Tc = cal_T(t,ip.Tc2);

% States
Ti = T(1);
pw = T(end-1);
S = T(end);
Rp = ip.Rp(S);
PwT = ip.PwT(Ti);
Pwc = ip.Pwc;
if PwT < Pwc
    Nw = 0;
else
    Nw = (PwT-pw)/Rp;
end
Vf = Ac*(H-S);

% ODEs
dSdt = Nw/(rho-ip.rhoe);
dTdt = zeros(m,1);
for i = 2:m-1
    dTdt(i) = alp*(1/(H-S)^2)*(1/dpsi^2)*(T(i-1)-2*T(i)+T(i+1)) - ((psi(i)-1)*dSdt/(H-S))*(T(i+1)-T(i-1))/(2*dpsi) - Fside*SB*A2*(T(i)^4-Tc^4)/(Vf*rho*Cp);
end
dTdt(1) = alp*(1/(H-S)^2)*(1/dpsi^2)*(2*T(2)-2*T(1)-2*Nw*dpsi*dHsub*(H-S)/k - Ftop*SB*(T(1)^4-Tu^4)*2*dpsi*(H-S)/k)...
        -((psi(1)-1)*dSdt/(H-S))*((H-S)*Nw*dHsub/k + Ftop*SB*(T(1)^4-Tu^4)*(H-S)/k) - Fside*SB*A2*(T(1)^4-Tc^4)/(Vf*rho*Cp);
dTdt(m) = alp*(1/(H-S)^2)*(1/dpsi^2)*(2*T(m-1)-2*T(m)+2*(S-H)*hb*dpsi*(T(m)-Tb)/k)-((psi(m)-1)*dSdt/(H-S))*((S-H)*hb*(T(m)-Tb)/k) - Fside*SB*A2*(T(m)^4-Tc^4)/(Vf*rho*Cp);


j = ip.nvial*Nw*Ac;
dpdt = ODE_PressureBalance(j,ip.Te,ip);

outputs = [dTdt; dpdt; dSdt];

end