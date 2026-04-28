import matlab.engine

engine = matlab.engine.start_matlab()


def process(data):
    # Convert nested Python 2D list to MATLAB struct
    # Assuming first column is Ts and second column is Qw
    engine.addpath("matlab")


    Ts = [[row[0] if len(row) > 0 else 0 for row in data]]
    print(Ts)
    Qw = [[row[1] if len(row) > 1 else 0 for row in data]]
    python_data = {
        'Ts': Ts,
        'Qw': Qw
    }

    # matlab_data = matlab.dictionary(python_data)
    
    processed_data = engine.farray(matlab.double(data))
    print(processed_data)
    result = dict()
    for key, val in processed_data.items():
        result[key] = list(x[0] for x in val)
        print("val", val, result[key])
    
    return result


def lyo(data):
    # get a list of the rows (in lists)
    print("matlabEngine.lyo called")
    engine.addpath("matlab")


    output = engine.lyo_process(matlab.double(data))

    # print("===================output================")
    print("OUTPUT", output)

    return output