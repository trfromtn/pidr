from . import matlabEngine

from fastapi import FastAPI, Form, Request
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()

# Serve static files from apy/resources directory
app.mount("/resources", StaticFiles(directory="apy/resources"), name="resources")
# Serve node_modules for local npm packages
app.mount("/node_modules", StaticFiles(directory="node_modules"), name="node_modules")


@app.get("/")
async def root():
    return FileResponse("apy/resources/home.html")

@app.get("/lyo-handson")
async def lyophilisation():
    return FileResponse("apy/resources/lyo-handson.html")

@app.get("/lyo-glide")
async def paste_data():
    return FileResponse("apy/resources/paste-data.html")

@app.post("/lyophilisation/array")
async def array(request: Request):
    """endpoint that receive data (POST request)"""

    data: dict[str, list[int]] = await request.json()
    d = data.get("data")
    processed_data = matlabEngine.lyo(d)

    matrix = [list(row) for row in processed_data]

    return {
        "received_data": matrix,
        "status": "success"
    }

@app.post("/lyophilisation/test")
async def test(request: Request):
    debug = True

    data: dict[str, list[int]] = await request.json()
    if debug: print(type(data), data)
    d = data.get("data")
    if debug: print(type(d), d)
    processed_data = matlabEngine.lyo(d)
    if debug: print(type(processed_data), processed_data)
    return {
        # "received_data": processed_data,
        "status": "success"
    }


@app.get("/matlab")
async def matlab():
    """matlab information for debug"""
    return {
        "current dir": matlabEngine.engine.cd(),
        "PATH": matlabEngine.engine.path()
    }

