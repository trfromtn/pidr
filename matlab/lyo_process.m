function output = lyo_process(input)
    
    % calls the simulator for each batch of input
    cd("<HARDCODED PATH>"); % dirty but couldn't find a sound workaround for this

    n = size(input, 1);
    results = [];

    for i = 1:n
        results = [results; custom_routine(input(i, :))];
    end 
    cd("..");

    output = results;
end
