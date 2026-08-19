function [objective, termination, direction] = event_precond_stochastic(t,y,ip)

T = y(1);
prob = y(2);
objective = [T-ip.Thold; prob-ip.prob_nuc];  % stop when reaching desired temperature
termination = [1;1];  % terminate ode solvers 
direction = [0;0];  % both directions

end