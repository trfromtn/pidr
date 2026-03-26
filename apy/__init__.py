
from .matlabEngine import engine 

from fastapi import FastAPI, Form, Request
from fastapi.responses import FileResponse, RedirectResponse
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


@app.post("/lyophilisation/simulate")
async def simulate(Tshelf: str = Form()):
    Tshelf = float(Tshelf)
    return {
        "Tshelf": Tshelf,
        'matlab response': list(engine.basic_func(Tshelf)[0])
    }

@app.post("/lyophilisation/array")
async def array(request: Request):
    body = await request.json()
    data = body.get('data')
    print(type(data), data)
    processed_data = [ [ ((i * x) if x is not None else None) for x in d] for i,d in enumerate(data)]
    return {
        "received_data": processed_data,
        "status": "success"
    }


@app.get("/matlab")
async def matlab():
    return {
        "current dir": engine.cd(),
        "PATH": engine.path()
    }

