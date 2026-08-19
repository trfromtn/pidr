function outputs = Sim_Freezing_StoVISF(ip)

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
ip.prob_nuc = rand;  % probability for nucleation

% Solve the ODEs
y0 = [ip.T01; 0];
opts_ode = odeset('Event', @(t,y) event_precond_stochastic(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
[t1,y1,~,~,ie] = ode15s (@(t1,y1) ODE_FreezingCoolPre2(t1,y1,ip), tspan, y0, opts_ode); 
T = y1(:,1); prob = y1(:,2); t = t1;

if ie == 1 
    warning("Preconditioning ends too early. Check temperature profile.")

elseif ie == 2
    warning("Nucleation occurs before precondioning ends. Skip VISF.")
    outputs.Tn = T(end);
    outputs.tn = t(end);

else

end


%% VISF
if ie == 2  % skip VISF because nucleation already occurs
    mloss = 0;
    ip.mws_new = ip.mws - mloss;
    ip.ms_new = ip.xs*ip.mws_new;  
    ip.mw_new = ip.mws_new-ip.ms_new;  
    ip.m0 = ip.mw_new;  
    tf = ip.tpost1;
    ip.Ptot(:,2) = ip.Ptot(:,2) + t(end);
    ip.Ptot = [ip.Ptot; [ip.Ptot(end,1),tf]];

else
    tf = ip.tpost1;
    y0 = [ip.mw;T(end);prob(end)];
    ip.Ptot(:,2) = ip.Ptot(:,2) + t(end);
    ip.Ptot = [ip.Ptot; [ip.Ptot(end,1),tf]];
    tspan = unique([(t(end):dt:tf)';tf]);  % define the time span
    opts_ode2 = odeset('Event', @(t,y) event_nucleation_stochastic(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
    [t1v,y1v] = ode15s (@(t,y) ODE_FreezingVISF2(t,y,ip), tspan, y0, opts_ode2);
    Tv = y1v(:,2); mv = y1v(:,1); tv= t1v; prob = y1v(:,3);
    
    if prob(end) < ip.prob_nuc
        warning('No nucleation occurs')
        outputs.Tn = 0;
        outputs.tn = 0;
    else
        outputs.Tn = Tv(end);
        outputs.tn = tv(end);
    end
    
    outputs.mv = mv;
    outputs.tv = tv;
    outputs.Pv = cal_P(tv,ip.Ptot);
    outputs.Tv = Tv;
    t = [t;tv(2:end)];
    T = [T;Tv(2:end)];
    
    % Update mass after VISF
    mloss = mv(1)-mv(end);
    ip.mws_new = ip.mws - mloss;  % total mass after evaporation via VISF
    ip.ms_new = ip.ms;  % mass of solute after VISF (assumed non-volatile)
    ip.mw_new = ip.mws_new-ip.ms_new;  % mass of water after evaporation via VISF
    ip.m0 = ip.mw_new;  % total mass after evaporation via VISF

end
m_ice = zeros(length(T),1);

%% Nucleation
% Find the equilibrium temperature
Tnuc = outputs.Tn;
K1 = 1;
K2 = -ip.Tf-Tnuc-ip.dHfus*ip.mw/(ip.Cpws*ip.mws);
K3 = ip.dHfus*ip.mw*ip.Tf/(ip.Cpws*ip.mws) - ip.ms*(ip.Kf/ip.Ms)*ip.dHfus/(ip.Cpws*ip.mws) + ip.Tf*Tnuc;
Teq_ini = 0.5*(-K2-sqrt(K2^2-4*K1*K3));  % new equilibrium temperature
mi = ip.mw - ip.ms*(ip.Kf/ip.Ms)/(ip.Tf-Teq_ini);  % mass of ice after first nucleation
outputs.mn = mi;

% Collect data
tf = ip.tpost1;
t = [t;t(end)+1e-3];
T = [T;Teq_ini];
m_ice = [m_ice;mi];


%% Solidification
% Solve the ODEs
tspan = unique([(t(end):dt:tf)';tf]);
opts_ode3 = odeset('Event', @(t,y) event_freezing_complete(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
[t2,y2] = ode15s (@(t,y) ODE_FreezingNucl(t,y,ip), tspan, mi, opts_ode3);

outputs_tmp = cal_freezing_interface(y2,ip);
outputs.r = outputs_tmp.r; outputs.l = outputs_tmp.l; outputs.t_rl = t2; outputs.H = outputs_tmp.H;

% Collect data
Teq = ip.Tf - ((ip.Kf/ip.Ms)*(ip.ms_new./(ip.m0-y2)));
ip.mi_fin = y2(end);
t = [t;t2(2:end)];
T = [T;Teq(2:end)];
m_ice = [m_ice;y2(2:end)];


%% Final Cooling
y0 = T(end);
tspan = unique([(t(end):dt:tf)';tf]);

% Solve the ODEs
opts_ode4 = odeset('RelTol',ip.tol,'AbsTol',ip.tol);
[t3,y3] = ode15s (@(t,y) ODE_FreezingCoolPost(t,y,ip), tspan, y0, opts_ode4);  
t = [t;t3(2:end)];
T = [T;y3(2:end)];
m_ice = [m_ice; m_ice(end)*ones(length(t3(2:end)),1)];


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
outputs.P  = cal_P(t,P_profile);

return