function outputs = ODE_FreezingCoolPost(t,y,ip)

% Important parameters and constants
Tc = cal_T(t,ip.Tc1);
Tu = cal_T(t,ip.Tu1);
Tg = cal_Tg(t,ip.Tg);
ms = ip.ms_new;
mw = ip.mw - ip.mi_fin;
mi = ip.mi_fin;
Cps = ip.Cps;
Cpw = ip.Cpw;
Cpi = ip.Cpi;
Ac = ip.Ac;
A1 = ip.A1f;

% Heat transfer
Qbot = ip.hs2*Ac*(Tg-y);
Qrad = ip.Fside1*ip.SB*A1*(Tc^4-y^4);
Qside = ip.hs3*A1*(Tg-y);
Qtop = ip.hs1*Ac*(Tu-y);
mCp = ms*Cps + mw*Cpw + mi*Cpi;

% ODEs
dTdt = (Qbot+Qside+Qtop+Qrad)/mCp;

% Output
outputs = dTdt;

return