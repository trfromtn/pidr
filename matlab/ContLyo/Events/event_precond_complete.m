function [objective, termination, direction] = event_precond_complete(t,T,ip)

Tavg = mean(T);
objective = Tavg-ip.Thold;  % stop when reaching desired temperature
termination = 1;  % terminate ode solvers 
direction = 0;  % both directions

end