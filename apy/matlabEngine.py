## this module is used by the server API to call matlab functions (in ../matlab dir)

import matlab.engine

engine = matlab.engine.start_matlab()



def lyo(data):
    # get a list of data rows (in lists)

    engine.addpath("matlab")
    input = matlab.double(data)
    output = engine.lyo_process(input)

    return output