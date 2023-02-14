from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def get_gibber():
    return {"text": "This is some simple gibberish text."}