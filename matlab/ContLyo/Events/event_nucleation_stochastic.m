function [objective, termination, direction] = event_nucleation_stochastic(t,y,ip)

prob = y(end);
objective = prob-ip.prob_nuc;  % stop when reaching desired temperature
termination = 1;  % terminate ode solvers 
direction = 0;  % both directions

end