## this module is used by the server API to call matlab functions (in ../matlab dir)

import matlab.engine
import numpy

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
    
    output = engine.farray(matlab.double(data))
    print(output)
    result = dict()
    for key, val in output.items():
        result[key] = list(x[0] for x in val)
        print("val", val, result[key])
    
    return result


def lyo(data):
    # get a list of the rows (in lists)
    print("+++++++++++++ matlabEngine.lyo called")

    engine.addpath("matlab")


    input = matlab.double(data)
    print("+++++++++++++ conversion ok", input)


    output = engine.lyo_process(input)
    print("++++++++++++ OUTPUT ok ")

    for key in output:
        o = output[key]
        if isinstance(o, matlab.double):
            output[key] = numpy.array(o)
        else:
            output[key] = (
                [numpy.array([x[0] for x in d]) for d in o]
            )
            print("%%%%%%%%%%%%%%%%", len(o))
            # print([engine.size(x) for x in o])

        # print(key, type(output[key]), len(output[key]), output[key][:min(3, len(output[key]))])


    # for key in output:
    #     try: 
    #         output[key] = numpy.array(output[key])
    #     except:
    #         print("++++++++++ERROR+++++++++", type(output[key]), [(type(x), len(x)) for x in output[key]])
    #         output[key] = numpy.array([])
    # print("+++++++++++++ back conversion ok")

    
    return output