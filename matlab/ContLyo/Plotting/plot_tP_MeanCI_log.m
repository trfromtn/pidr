function plot_tP_MeanCI_log(t,T,T_low,T_high,linestyle1,linestyle2)

mean = T;

curve1 = T_high;
curve2 = T_low;
a = [t, fliplr(t)];
area = [curve1, fliplr(curve2)];
semilogx(t, mean, linestyle1{:});
hold on; 
fill(a, area, linestyle2{:});
ylabel('Time of first nucleation (s)'); xlabel('VISF Pressure (Pa)')

end