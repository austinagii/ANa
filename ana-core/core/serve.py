from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import senti 

class SentimentRequest(BaseModel):
    text: str

class SentimentResponse(BaseModel):
    sentiment: str


app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/predict")
def predict(request: SentimentRequest) -> SentimentResponse:
    sentiment = senti.predict_sentiment(request.text)
    print(f"The model returned the sentiment: {sentiment}")
    return SentimentResponse(sentiment=sentiment) 
