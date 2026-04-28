function output = custom_routine(input) 


%% Pre-simulation

addpath('Input Data', 'Model Equations', 'Events','Exporting Graphics','Plotting', ...
    'Simulations','Calculations');

% Mode of simulation
Lyo = 'off';  % complete simulation for the entire lyo process  
FreezingSto = 'off';  % freezing with stochastic ice nucleation  
FreezingVISF = 'off';  % freezing with controlled nucleation via VISF
FreezingStoVISF = 'off';  % freezing with stochastic ice nucleation   
PrimDry = 'off';  % primary drying
Choked = 'off';  % primary drying with choked condition
SecDry = 'off';  % secondary drying
All = 'on';  % run all simulations
None = 'off';  % run nothing

% Check mode of simulation
switch All
case 'on'
    [Lyo,FreezingVISF,FreezingSto,PrimDry,SecDry,Choked] = deal('on');
end

switch None 
case 'on'
    [Lyo,FreezingVISF,FreezingSto,PrimDry,SecDry,Choked] = deal('off');
end


%% MARK: Complete continuous lyophilization
switch Lyo
case 'on'

% Parameters
ip0 = get_inputdata;
% ip0.Vl = 3e-6;  % modify any inputs here
ip = input_processing(ip0);

% Simulation and obtain solutions
% sol 1 = freezing, sol 2 = primary drying, sol 3 = secondary drying
tic; [sol1, sol2, sol3] = Sim_Lyo(ip); toc;

output.continuous_lyo1 = sol1;
output.continuous_lyo2 = sol2;
output.continuous_lyo3 = sol3;

% Plotting
% fig_all = figure(Name="continuous lyo"); 
% plot_all(sol1,sol2,sol3,ip)

end

%% MARK: Freezing with stochastic ice nucleation
switch FreezingSto
case 'on'

ip0 = get_inputdata;
ip = overwrite_inputdata(ip0,'stochastic_freezing');
% ip.Tg = 260; ip.tpre1 = 0;  % skip preconditioning
ip = input_processing(ip);
Tn_Sto = [];
rng(0)

% fig_freeze = figure(Name="sto"); 

for i = 1:5
    tic; sol = Sim_Freezing_Sto(ip); toc;
    time = sol.t; Temp = sol.T; Tg = sol.Tg;
    Tn_Sto = [Tn_Sto;sol.tn];
    
    % plot(time/3600,Temp,'linewidth',1.5); hold on; 
    % ylabel({'Product temperature (K)'}); xlabel('Time (h)')

end

output.freeze = sol; % il y a plusieurs solutions, je sais pas les interpréter

Tmean_Sto = mean(Tn_Sto);
Tsd_Sto = sqrt(var(Tn_Sto));


end


%% Freezing with VISF
switch FreezingVISF
case 'on'

% Parameters
ip0 = get_inputdata;
ip = input_processing(ip0);

% Simulation and obtain solutions
sol = Sim_Freezing_VISF(ip);
output.freezing_visf = sol;
% time = sol.t; Temp = sol.T; Tg = sol.Tg;

% Plotting
% fig_VISF = figure(Name="visf"); 
% plot_Tavg(time/3600,Temp); 

end


%% Freezing with stochastic ice nucleation + VISF
switch FreezingStoVISF
case 'on'
ip0 = get_inputdata;
ip = overwrite_inputdata(ip0,'StoVISF_freezing');
ip.Ptot = [1e5, 1e4, 1e4, 1e5; 0, 60, 60+ip.tVISF, 2*60+ip.tVISF]';
ip = input_processing(ip);
Tn_VISF = [];
rng(0)

% fig_freeze = figure(Name="sto+visf"); 
for i = 1:5
    tic; sol = Sim_Freezing_StoVISF2(ip); toc;
    % time = sol.t; Temp = sol.T; Tg = sol.Tg;
    Tn_VISF = [Tn_VISF;sol.tn];
    % plot(time/3600,Temp,'linewidth',1.5); hold on; 
    % ylabel({'Product temperature (K)'}); xlabel('Time (h)')

end
output.freezing_stovisf = sol; % de nouveau, plusieurs solutions?

Tmean_VISF = mean(Tn_VISF);
Tsd_VISF = sqrt(var(Tn_VISF));


end


%% MARK: Primary Drying 
switch PrimDry
case 'on'

% Parameters
ip0 = get_inputdata;
ip0.Tb2 = input(1); % CUSTOM
ip = input_processing(ip0);

% Simulation and obtain solutions
sol = Sim_1stDrying(ip);
time = sol.t; Temp = sol.T; S = sol.S; 
Tp = mean(Temp,2); Tb = sol.Tb;

% Plotting
% figure(Name="prymary 1"); plot_Tp(time/3600,Tp);
% figure(Name="primary 2"); plot_S(time/3600,S*100);

output.primary = sol;

end


%% MARK: Primary Drying with Choked Flow 
switch Choked
case 'on'

% Parameters
ip0 = get_inputdata;
ip = input_processing(ip0);

% Simulation and obtain solutions
sol = Sim_1stDrying_Choked(ip);
time = sol.t; Temp = sol.T;
Tp = mean(Temp,2); Tb = sol.Tb;

% Plotting
% fig_ch = figure(Name="primary choked flow");
% tiledlayout(1,3,"TileSpacing","loose","Padding","compact")
% nexttile(1); plot(time/3600,sol.P,'linewidth',2); hold on
% ylabel({'Pressure (Pa)'}); xlabel('Time (h)')
% ylim([0 25]); xticks(0:2:10); text(.83,.1,'(A)','Units','normalized','FontSize', 10,'fontweight', 'bold');
% graphics_setup('1by3s')
% nexttile(2); plot(time/3600,sol.S*100,'linewidth',2); hold on
% ylabel({'Sublimation front position (cm)'}); xlabel('Time (h)'); xticks(0:2:10);
% text(.83,.1,'(B)','Units','normalized','FontSize', 10,'fontweight', 'bold');
% graphics_setup('1by3s')
% nexttile(3); plot(time/3600,Tp,'linewidth',2); hold on
% ylabel({'Product temperature (K)'}); xlabel('Time (h)'); xticks(0:2:10);
% text(.83,.1,'(C)','Units','normalized','FontSize', 10,'fontweight', 'bold');
% graphics_setup('1by3')

output.primary_chocked = sol;

end


%% Secondary Drying
switch SecDry
case 'on'

% Parameters
ip0 = get_inputdata;
ip = input_processing(ip0);

% Simulation and obtain solutions
sol = Sim_2ndDrying(ip);
time = sol.t;
cw = sol.cw; cw_avg = mean(cw,2);
Temp = sol.T; Tp = mean(Temp,2); Tb = sol.Tb;

% Plotting
% fig_sec = figure(Name="secondary");
% plot_cw(time/3600,cw_avg)
output.secondary = sol;

end


end
