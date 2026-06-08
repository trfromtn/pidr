function output = custom_routine(input) 

% very minimal version of the original routine. It takes a single dimension array as input 

addpath('Input Data', 'Model Equations', 'Events','Exporting Graphics','Plotting', ...
    'Simulations','Calculations');



% Parameters
ip0 = get_inputdata;
% ip0.Vl = 3e-6;  % modify any inputs here


% USER INPUT
ip0.tpost1 = input(1); 
ip0.Vl = input(2);
ip0.Tb2 = input(3);
ip0.Pwc = input(4);
ip0.tpost2 = input(5);
ip0.Tb3 = input(6);
ip0.cfin = input(7);


% preprocessing of 
ip = input_processing(ip0);


% Simulation and obtain solutions
% sol 1 = freezing, sol 2 = primary drying, sol 3 = secondary drying
tic; [sol1, sol2, sol3] = Sim_Lyo(ip); toc;


cw = sol3.cw;
last = size(cw,1) * size(cw,2);


output = [sol3.cw(last) sol1.mi(length(sol1.mi))];

