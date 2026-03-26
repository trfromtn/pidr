
from . import matlabEngine

from fastapi import FastAPI, Form, Request
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# Serve static files from apy/resources directory
app.mount("/resources", StaticFiles(directory="apy/resources"), name="resources")


@app.get("/")
async def root():
    return FileResponse("apy/resources/home.html")

@app.get("/lyophilisation")
async def lyophilisation():
    return FileResponse("apy/resources/lyophilisation.html")



@app.post("/lyophilisation/array")
async def array(request: Request):
    debug = True

    data: dict[str, list[int]] = await request.json()
    if debug: print(type(data), data)
    d = data.get("data")
    if debug: print(type(d), d)
    processed_data = matlabEngine.process(d)
    if debug: print(type(processed_data), processed_data)
    return {
        "received_data": processed_data,
        "status": "success"
    }

# @app.post("/lyophilisation/simulate")
# async def simulate(Tshelf: str = Form()):
#     Tshelf = float(Tshelf)
#     return {
#         "Tshelf": Tshelf,
#         'matlab response': list(engine.basic_func(Tshelf)[0])
#     }

@app.get("/matlab")
async def matlab():
    """matlab information for debug"""
    return {
        "current dir": matlabEngine.engine.cd(),
        "PATH": matlabEngine.engine.path()
    }

