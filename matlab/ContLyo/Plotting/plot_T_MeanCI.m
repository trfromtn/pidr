function plot_T_MeanCI(t,T,T_low,T_high,linestyle1,linestyle2)

mean = T;

curve1 = T_high;
curve2 = T_low;
a = [t, fliplr(t)];
area = [curve1, fliplr(curve2)];
plot(t, mean, linestyle1{:});
hold on; 
fill(a, area, linestyle2{:});
ylabel('Temperature (K)')
xlabel('Time (h)')

end