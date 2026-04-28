function outputs = overwrite_inputdata(ip2,data)

ip = ip2;

switch data
case 'expcon1_freezing'
ip.freezing = "suspended"; 
ip.hs1 = 7;  
ip.hs3 = 15; 
ip.hs2 = 18;  
ip.T01 = 280; 
ip.Tnuc = 263.18; 
ip.Tg = load('Data_Con_FreezeGas').Data;  
ip.Tc1 = 272;
ip.Tu1 = 272;
ip.tpost1 = 5.53150681*3600;  

case 'expcon1_primdry'
ip.hb2 = 16; 
ip.T02 = 231;  
ip.Tc2 = 275;
ip.Tu2 = ip.Tc2; 
ip.Tb2 = 263;
ip.Rp1 = 3.4e7;
ip.Rp2 = 1e0;  

case 'expcon1_secdry'
ip.Vl = 2e-6; 
ip.hb3 = 16;
ip.T03 = 273; 
ip.Tb3 = 293;
ip.Tc3 = 285;
ip.Tu3 = ip.Tc3;
ip.cw0 = 0.088;  
ip.Ea = 20500; 
ip.fa = 4.2e-1;  

case 'expbatch1_primdry'
ip.rhof = 917;
ip.Cpf = 1967.8;
ip.kf = 2.30; 
ip.rhoe = 252; 
ip.d = 7.125*2e-3;  % 2R vial 
ip.H2 = 0.00715;
ip.hb2 = 22; 
ip.T02 = 228.15;  
ip.Tb2 = @(x) min(228.15+(.25/60)*x,258.15);
ip.Pwc = 15;
ip.Rp0 = 3.8e4;
ip.Rp1 = 3.1e7; 
ip.Rp2 = 1e1;
ip.Fside2 = 0;
ip.Ftop2 = 0;

case 'expbatch2_secdry'
ip.Vl = 1.5e-6; 
ip.d = 7.125*2e-3; 
ip.hb3 = 7;
ip.T03 = 264;
ip.cw0 = 0.0603;
ip.cfin = 6e-3;
ip.Ea = 5920; 
ip.fa = 1.2e-3;
ip.Tb3 = @(x) min(264+(.5/60)*x,312);
ip.Fside3 = 0;
ip.Ftop3 = 0;

case 'stochastic_freezing'
ip.T01 = 280;
ip.Thold = 268;
% ip.Tg = 260;
ip.tpre1 = .25*3600;
ip.Tg = [268, 268, 260, 260; 0, ip.tpre1, ip.tpre1+60, 2*3600]'; 
ip.dt1 = 10;
ip.hs2 = 60;
ip.hs3 = 60;
ip.tpost1 = 1*3600;
ip.Tc1 = ip.Tg;
ip.Tu1 = ip.Tg;
ip.bn = 1e-9;
ip.kn = 12;

case 'StoVISF_freezing'
ip.T01 = 280;
ip.Ptot = [1e5, 1e4, 1e4, 1e5; 0, 60, 60+ip.tVISF, 2*60+ip.tVISF]'; 
ip.Thold = 268;
% ip.Tg = 260;
ip.tpre1 = .25*3600;
ip.Tnuc = 260;
ip.Tg = [268, 268, 260, 260; 0, ip.tpre1, ip.tpre1+60, 2*3600]'; 
ip.dt1 = 5;
ip.hs2 = 60;
ip.hs3 = 60;
ip.tpost1 = 1*3600;
ip.Tc1 = ip.Tg;
ip.Tu1 = ip.Tg;
ip.bn = 1e-9;
ip.kn = 12;

case 'VISF'
ip.Tg = load('Data_VISF.mat').Data.Tb;
ip.P = load('Data_VISF.mat').Data.P;
ip.T01 = load('Data_VISF.mat').Data.T(1,1);
ip.tpre1 = 300;
ip.tpost1 = 431;
ip.Tnuc = 266.5;
ip.Thold = 200;
ip.hm = 1.3e-2;  % mass transfer coefficient (kg/m2-s)
ip.Tc1 = 282;
ip.Tu1 = ip.Tc1;
ip.dt1 = 1;
end

outputs = ip;

return