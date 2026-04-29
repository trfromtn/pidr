function output = lyo_process(input)
    
    % calls the simulator for each batch of input
    cd("C://Users/Public/PIDR/pidr/matlab/ContLyo/")
    results = [];
    for i = 1:length(input)
        x = custom_routine(input(i));
        results = [results, x];
    end 
    cd("..");


    % tr = transpose_struct_array(results);
    % ss = SSA2AAS(results);

    % output.r = results;
    % output.t = tr;
    % output.s = ss;


    output = SSA2AAS(results);

end


function transposed = transpose_struct_array(struct_array)
    % Takes: array of structs A (each containing structs B)
    % Returns: struct A with fields containing arrays of structs B
    %
    % Example:
    %   Input:  struct_array(1).field1 = B1, struct_array(1).field2 = B2
    %           struct_array(2).field1 = B3, struct_array(2).field2 = B4
    %   Output: transposed.field1 = [B1, B3]
    %           transposed.field2 = [B2, B4]
    
    if isempty(struct_array)
        transposed = struct();
        return;
    end
    
    % Get field names from first struct
    field_names = fieldnames(struct_array(1));
    transposed = struct();
    
    % For each field, collect all values into an array
    for f = 1:length(field_names)
        field_name = field_names{f};
        field_array = [];
        
        % Collect this field from all structs
        for i = 1:length(struct_array)
            field_value = struct_array(i).(field_name);
            if i == 1
                field_array = field_value;
            else
                % Concatenate - works for structs and numeric arrays
                field_array = [field_array, field_value];
            end
        end
        
        transposed.(field_name) = field_array;
    end
end


function array_array_struct = SSA2AAS(struct_struct_array)
    % Takes: Array of Structs of Structs
    % Returns: Struct of Arrays where field names are concatenated (name1_name2)
    %
    % Example:
    %   Input:  struct_struct_array(1).freezing.temperature = [1,2,3]
    %           struct_struct_array(1).freezing.pressure = [5,6,7]
    %           struct_struct_array(2).freezing.temperature = [8,9,10]
    %           struct_struct_array(2).freezing.pressure = [11,12,13]
    %   Output: array_array_struct.freezing_temperature = {[1,2,3], [8,9,10]}
    %           array_array_struct.freezing_pressure = {[5,6,7], [11,12,13]}
    
    if isempty(struct_struct_array)
        array_array_struct = struct();
        return;
    end
    
    array_array_struct = struct();
    
    for i = 1:length(struct_struct_array)
        s = struct_struct_array(i);
        field_names_level1 = fieldnames(s);
        
        for j = 1:length(field_names_level1)
            name1 = field_names_level1{j};
            nested_struct = s.(name1);
            
            % Only process if it's a struct
            if isstruct(nested_struct)
                field_names_level2 = fieldnames(nested_struct);
                
                for k = 1:length(field_names_level2)
                    name2 = field_names_level2{k};
                    combined_name = [name1 '__' name2];
                    value = nested_struct.(name2);
                    
                    % Initialize or concatenate
                    if ~isfield(array_array_struct, combined_name)
                        array_array_struct.(combined_name) = {};
                    end
                    array_array_struct.(combined_name){i} = value;
                end
            end
        end
    end
    
    % Convert cell arrays to proper arrays if all elements are numeric
    field_names = fieldnames(array_array_struct);
    for f = 1:length(field_names)
        field_name = field_names{f};
        cell_array = array_array_struct.(field_name);
        
        % Check if all elements are numeric and can be concatenated
        all_numeric = all(cellfun(@isnumeric, cell_array));
        if all_numeric
            % Try to concatenate into single numeric array
            try
                array_array_struct.(field_name) = cell2mat(cell_array);
            catch
                % Keep as cell array if concatenation fails
            end
        end
    end
end

function name = combine(name1, name2) 
    name = [name1 '_' name2];
end