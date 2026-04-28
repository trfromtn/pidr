function [x_mean, x_low, x_high] = cal_CI(sample,CL)

x = sample;
nsize = height(x);
x_sort = sort(x);
x_low = x_sort(floor(0.5*(1-CL)*nsize),:);
x_high = x_sort(ceil((1-0.5*(1-CL))*nsize),:);
x_mean = mean(x);


return