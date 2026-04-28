function outputs = Sim_Freezing_VISF(ip)

%% Cooling, Pre-conditioning
% Correct the gas temperature profile
if length(ip.Tg) > 1
    if ip.Tg(end,2) < ip.tpost1
        Tg_add = [ip.Tg(end,1), ip.tpost1];
        ip.Tg = [ip.Tg; Tg_add];
    end
end

% Parameters for ODE solver
tf = ip.tpre1;  % final time
dt = ip.dt1;  % data collection frequency from the ODE solver
tspan = unique([(0:dt:tf)';tf]);  % define the time span
T0 = ip.T01;  % initial conditions

% Solve the ODEs
opts_ode = odeset('Event', @(t,y) event_precond_complete(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
[t1,y1] = ode15s (@(t1,y1) ODE_FreezingCoolPre(t1,y1,ip), tspan, T0, opts_ode);
t = t1;
T = y1;

if t(end) < tf
    warning('Preconditioning ends too early. Check temperature profile.')
end


%% VISF
if T(end) > ip.Tnuc
    VISF = 1;
    
    % Parameters for ODE solver
    tf = ip.tpost1;
    y0 = [ip.mw; y1(end)];
    ip.Ptot(:,2) = ip.Ptot(:,2) + t(end);
    ip.Ptot = [ip.Ptot; [ip.Ptot(end,1),tf]];
    tspan = unique([(t(end):dt:tf)';tf]);  % define the time span
    
    % Solve the ODEs
    opts_ode2 = odeset('Event', @(t,y) event_nucleation_start(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
    [t1v,y1v] = ode15s (@(t,y) ODE_FreezingVISF(t,y,ip), tspan, y0, opts_ode2);
    
    % Collect data
    t = [t;t1v];
    T = [T;y1v(:,2)];
    
    outputs.mv = y1v(:,1);
    outputs.tv = t1v;
    outputs.Pv = cal_P(t1v,ip.Ptot);
    outputs.Tv = y1v(:,2);
  

    % Check if the temperature is above nucleation temperature
    if T(end) > ip.Tnuc
        warning('VISF temperature is higher than the target nucleation temperature.')
    end

    mloss = y1v(1,1)-y1v(end,1);
else
    warning('Nucleation occurs before VISF. VISF is skipped.')
    VISF = 0;
    mloss = 0;
end
m_ice = zeros(length(T),1);
outputs.tn = t(end);

if t(end) >= ip.tpost1
    warning('Simulation terminates at VISF step. Extend the final time.')
end

% Update mass after VISF
ip.mws_new = ip.mws - mloss;  % total mass after evaporation via VISF
ip.ms_new = ip.ms;  % mass of solute after VISF (assumed non-volatile)
ip.mw_new = ip.mws_new-ip.ms_new;  % mass of water after evaporation via VISF
ip.m0 = ip.mw_new;  % total mass after evaporation via VISF


%% Nucleation
% Find the equilibrium temperature
K1 = 1;
K2 = -ip.Tf-ip.Tnuc-ip.dHfus*ip.mw/(ip.Cpws*ip.mws);
K3 = ip.dHfus*ip.mw*ip.Tf/(ip.Cpws*ip.mws) - ip.ms*(ip.Kf/ip.Ms)*ip.dHfus/(ip.Cpws*ip.mws) + ip.Tf*ip.Tnuc;
Teq_ini = 0.5*(-K2-sqrt(K2^2-4*K1*K3));  % new equilibrium temperature
mi = ip.mw - ip.ms*(ip.Kf/ip.Ms)/(ip.Tf-Teq_ini);  % mass of ice after first nucleation
 
% Collect data
tf = ip.tpost1;
t = [t;t(end)];
T = [T;Teq_ini];
m_ice = [m_ice;mi];
tspan = unique([(t(end):dt:tf)';tf]);


%% Solidification
% Solve the ODEs
opts_ode3 = odeset('Event', @(t,y) event_freezing_complete(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
[t2,y2] = ode15s (@(t,y) ODE_FreezingNucl(t,y,ip), tspan, mi, opts_ode3);

outputs_tmp = cal_freezing_interface(y2,ip);
outputs.r = outputs_tmp.r; outputs.l = outputs_tmp.l; outputs.t_rl = t2; outputs.H = outputs_tmp.H;

% Collect data
Teq = ip.Tf - ((ip.Kf/ip.Ms)*(ip.ms_new./(ip.m0-y2)));
ip.mi_fin = y2(end);
t = [t;t2];
T = [T;Teq];
m_ice = [m_ice;y2];

if t(end) >= ip.tpost1
    warning('Simulation terminates at solidification step. Extend the final time.')
end


%% Final Cooling
y0 = T(end);
tspan = unique([(t(end):dt:tf)';tf]);

% Solve the ODEs
opts_ode4 = odeset('RelTol',ip.tol,'AbsTol',ip.tol);
[t3,y3] = ode15s (@(t,y) ODE_FreezingCoolPost(t,y,ip), tspan, y0, opts_ode4);  
t = [t;t3];
T = [T;y3];
m_ice = [m_ice; m_ice(end)*ones(length(t3),1)];


%% Export
P_profile = ip.Ptot;
P_profile = [[P_profile(1,1),0]; P_profile];

outputs.Tg = cal_Tg(t,ip.Tg);
outputs.Tw = cal_T(t,ip.Tc1);
outputs.t = t;
outputs.T = T;
outputs.S = ip.S0*ones(length(outputs.t),1);
outputs.cw = ip.cw0*ones(length(outputs.t),1);
outputs.mi = m_ice;
outputs.mloss = mloss;
if VISF == 1
    outputs.P  = cal_P(t,P_profile);
else
    outputs.P = 1e5*ones(length(outputs.t),1);
end

return