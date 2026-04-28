function outputs = ODE_FreezingCoolPre(t,y,ip)

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

Qbot = ip.hs2*Ac*(Tg-y);
Qrad = ip.Fside1*ip.SB*A1*(Tc^4-y^4);
Qside = ip.hs3*A1*(Tg-y);
Qtop = ip.hs1*Ac*(Tu-y);
mCp = ms*Cps + mw*Cpw;

dTdt = (Qbot+Qside+Qtop+Qrad)/mCp;

% Output
outputs = dTdt;

return