from fastapi import FastAPI, Form
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


@app.post("/lyophilisation")
async def receive_data(Tshelf: str = Form()):
    return FileResponse("apy/resources/lyophilisation-results.html")


