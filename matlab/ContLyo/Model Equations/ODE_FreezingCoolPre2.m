function outputs = ODE_FreezingCoolPre2(t,y,ip)

% Important parameters and constants
Tc = cal_T(t,ip.Tc1);
Tu = cal_T(t,ip.Tu1);
Tg = cal_Tg(t,ip.Tg);
ms = ip.ms;
mw = ip.mw;
Cps = ip.Cps;
Cpw = ip.Cpw;
Ac = ip.Ac;
A1 = ip.A1l;

T = y(1);
prob = y(2);

Qbot = ip.hs2*Ac*(Tg-T);
Qrad = ip.Fside1*ip.SB*A1*(Tc^4-T^4);
Qside = ip.hs3*A1*(Tg-T);
Qtop = ip.hs1*Ac*(Tu-T);
mCp = ms*Cps + mw*Cpw;

dTdt = (Qbot+Qside+Qtop+Qrad)/mCp;

if T < ip.Tf
    J = ip.bn*(ip.Tf-T)^ip.kn;
    dprobdt = J*ip.Vl*(1-prob);
else
    dprobdt = 0;
end

% Output
outputs = [dTdt; dprobdt];

return