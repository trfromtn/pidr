from fastapi import FastAPI, Form
from fastapi.responses import FileResponse, RedirectResponse
import jinja2 as ji

from .matlabEngine import engine

app = FastAPI()

env = ji.Environment(loader=ji.FileSystemLoader("apy/templates"))
template = env.get_template("tuto.jinja")



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


@app.get("/matlab")
async def matlab():
    return {
        "current dir": engine.cd(),
        "PATH": engine.path()
    }

@app.get("/test")
async def test(name = None):
    return template.render(nom = name)