function [objective, termination, direction] = event_nucleation_start(t,y,ip)

T = y(end);
objective = T-ip.Tnuc;  % stop when reaching desired temperature
termination = 1;  % terminate ode solvers 
direction = 0;  % both directions

end