function outputs = ODE_2ndDrying(t,y,ip)

% Extract all data
m = ip.nz3;
dz = ip.dz3;
rho = ip.rhoe;
Cp = ip.Cpe;
q1 = ip.ke/(ip.rhoe*ip.Cpe);
q2 = ip.rhod*ip.dHdes/(ip.rhoe*ip.Cpe);
Fside = ip.Fside3;
Ftop = ip.Ftop3;
A3 = ip.A3;
SB = ip.SB;
V = ip.Ac*ip.H3;

% Shelf/wall temperatures
Tc = cal_T(t,ip.Tc3);
Tu = cal_T(t,ip.Tu3);
Tb = cal_T(t,ip.Tb3);

% States
T = y(1:m);
cs = y(m+1:2*m);

% ODE
dcdt = zeros(m,1);
dTdt = zeros(m,1);

% Desorption
for i = 1:m
    dcdt(i) = -cal_ks(T(i),ip)*cs(i);
end

% Heat transfer
for i = 2:m-1
    dTdt(i) = (q1/dz^2)*(T(i-1) - 2*T(i) + T(i+1)) + q2*dcdt(i) - Fside*SB*A3*(T(i)^4-Tc^4)/(V*rho*Cp) ;
end
dTdt(1) = 2*((q1/dz^2)*(T(2)-T(1))) + q2*dcdt(1) - 2*(Ftop*SB/(ip.rhoe*ip.Cpe*dz))*(T(1)^4-Tu^4) - Fside*SB*A3*(T(i)^4-Tc^4)/(V*rho*Cp) ;
dTdt(m) = 2*((q1/dz^2)*(T(m-1)-T(m))) + q2*dcdt(m) - 2*(ip.hb3/(ip.rhoe*ip.Cpe*dz))*(T(m)-Tb) - Fside*SB*A3*(T(i)^4-Tc^4)/(V*rho*Cp);

% Outputs
outputs = [dTdt;dcdt];

return