function outputs = Sim_Freezing_Sto(ip)

%% Pre-conditioning
% Correct the gas temperature profile
if length(ip.Tg) > 1
    if ip.Tg(end,2) < ip.tpost1
        Tg_add = [ip.Tg(end,1), ip.tpost1];
        ip.Tg = [ip.Tg; Tg_add];
    end
end

% Parameters
ip.prob_nuc = rand;  % probability for nucleation
dt = ip.dt1;  % data collection frequency from the ODE solver

if ip.tpre1 == 0
    tf = ip.tpost1;  % skip preconditioning
    tspan = unique([(0:dt:tf)';tf]);  % define the time span

    % Simulation
    y0 = [ip.T01; 0];
    opts_ode = odeset('Event', @(t,y) event_nucleation_stochastic(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
    [t1,y1] = ode15s (@(t1,y1) ODE_FreezingCoolPre2(t1,y1,ip), tspan, y0, opts_ode); 
    T = y1(:,1); prob = y1(:,2); t = t1;
    outputs.Tn = T(end);
    outputs.tn = t(end);
   
else
    tf = ip.tpre1;
    tspan = unique([(0:dt:tf)';tf]);  % define the time span

    % Simulation
    y0 = [ip.T01; 0];
    opts_ode = odeset('Event', @(t,y) event_precond_stochastic(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
    [t1,y1,~,~,ie] = ode15s (@(t1,y1) ODE_FreezingCoolPre2(t1,y1,ip), tspan, y0, opts_ode); 
    T = y1(:,1); prob = y1(:,2); t = t1;
    
    if ie == 1 
        warning("Preconditioning ends too early. Check temperature profile.")
        tf = ip.tpost1;
        y0 = y1(end,:);
        tspan = unique([(t(end):dt:tf)';tf]); 
        opts_ode = odeset('Event', @(t,y) event_nucleation_stochastic(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
        [t1,y1] = ode15s (@(t1,y1) ODE_FreezingCoolPre2(t1,y1,ip), tspan, y0, opts_ode); 
        T = [T;y1(2:end,1)]; prob = [prob;y1(:,2)]; t = [t;t1(2:end)];
        outputs.Tn = T(end);
        outputs.tn = t(end);
    
    elseif ie == 2
        warning("Nucleation occurs before precondioning ends.")
        outputs.Tn = T(end);
        outputs.tn = t(end);
        tf = ip.tpost1;
    
    else
        tf = ip.tpost1;
        y0 = y1(end,:);
        tspan = unique([(t(end):dt:tf)';tf]); 
        opts_ode = odeset('Event', @(t,y) event_nucleation_stochastic(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
        [t1,y1] = ode15s (@(t1,y1) ODE_FreezingCoolPre2(t1,y1,ip), tspan, y0, opts_ode); 
        T = [T;y1(2:end,1)]; prob = [prob;y1(:,2)]; t = [t;t1(2:end)];
        outputs.Tn = T(end);
        outputs.tn = t(end);
    end

end
m_ice = zeros(length(T),1);


%% No VISF
mloss = 0;
ip.mws_new = ip.mws - mloss;
ip.ms_new = ip.xs*ip.mws_new;  % mass of solute after evaporation via VISF
ip.mw_new = ip.mws_new-ip.ms_new;  % mass of water after evaporation via VISF
ip.m0 = ip.mw_new;  % total mass after evaporation via VISF


%% Nucleation
Tnuc = outputs.Tn;
K1 = 1;
K2 = -ip.Tf-Tnuc-ip.dHfus*ip.mw/(ip.Cpws*ip.mws);
K3 = ip.dHfus*ip.mw*ip.Tf/(ip.Cpws*ip.mws) - ip.ms*(ip.Kf/ip.Ms)*ip.dHfus/(ip.Cpws*ip.mws) + ip.Tf*Tnuc;
Teq_ini = 0.5*(-K2-sqrt(K2^2-4*K1*K3));  % new equilibrium temperature
mi = ip.mw - ip.ms*(ip.Kf/ip.Ms)/(ip.Tf-Teq_ini);  % mass of ice after first nucleation
outputs.mn = mi;
m_ice = [m_ice;mi];
t = [t;t(end)+1e-3];
T = [T;Teq_ini];


%% Solidification
tspan = unique([(t(end):dt:tf)';tf]);
opts_ode2 = odeset('Event', @(t,y) event_freezing_complete(t,y,ip),'RelTol',ip.tol,'AbsTol',ip.tol);
[t2,y2] = ode15s (@(t,y) ODE_FreezingNucl(t,y,ip), tspan, mi, opts_ode2);
Teq = ip.Tf - ((ip.Kf/ip.Ms)*(ip.ms_new./(ip.m0-y2)));
ip.mi_fin = y2(end);
t = [t;t2(2:end)];
T = [T;Teq(2:end)];
m_ice = [m_ice;y2(2:end)];


%% Final Cooling
opts_ode3 = odeset('RelTol',ip.tol,'AbsTol',ip.tol);
y0 = T(end);
tspan = unique([(t(end):dt:tf)';tf]);
[t3,y3] = ode15s (@(t,y) ODE_FreezingCoolPost(t,y,ip), tspan, y0, opts_ode3); 
t = [t;t3(2:end)];
T = [T;y3(2:end)];
m_ice = [m_ice; m_ice(end)*ones(length(t3(2:end)),1)];


%% Export
outputs.Tg = cal_Tg(t,ip.Tg);
outputs.Tw = cal_T(t,ip.Tc1);
outputs.t = t;
outputs.T = T;
outputs.S = ip.S0*ones(length(outputs.t),1);
outputs.cw = ip.cw0*ones(length(outputs.t),1);
outputs.mi = m_ice;


return