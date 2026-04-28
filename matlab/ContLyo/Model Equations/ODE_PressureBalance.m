function outputs = ODE_PressureBalance(jin,T,ip)
    jout = min(jin,ip.jmax);
    dpdt = (jin-jout)*ip.R*T/(ip.Vc*ip.Mw*1e-3);
    outputs = dpdt;
end