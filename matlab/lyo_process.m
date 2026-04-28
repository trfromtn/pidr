function output = lyo_process(input)
    cd("C://Users/Public/PIDR/pidr/matlab/ContLyo/")

    results = [];
    for i = 1:length(input)
        x = custom_routine(input(i));
        results = [results, x];
    end 
    
    % Convert to flattened rows for Python (sample at 10 time points)
    output = results
    output(1).continuous_lyo1
    output(1).continuous_lyo2
    output(1).continuous_lyo3
    output(1).freeze
    output(1).freezing_visf
    output(1).primary
    output(1).primary_chocked
    output(1).secondary
end

function flattened = flatten_results(struct_array, num_samples)
    % Sample each solution at num_samples time points and flatten into rows
    % Each row = one input, values sampled from all fields at given times
    
    flattened = [];
    
    for i = 1:length(struct_array)
        s = struct_array(i);
        row = [];
        
        for field = fieldnames(s)'
            field_name = field{1};
            field_value = s.(field_name);
            
            % If it has time data (ODE solution)
            if isstruct(field_value) && isfield(field_value, 'x') && isfield(field_value, 'y')
                % Sample at num_samples equally spaced time points
                time_points = linspace(field_value.x(1), field_value.x(end), num_samples);
                sampled = interp1(field_value.x, field_value.y', time_points, 'linear', 'extrap')';
                sampled_flat = sampled(:)'; % flatten to row
                row = [row, sampled_flat];
            elseif isnumeric(field_value)
                % Already numeric, just flatten
                row = [row, field_value(:)'];
            end
        end
        
        flattened = [flattened; row];
    end
end