# fastapi → create API
# uvicorn → run server
# numpy → send data to model

from fastapi import FastAPI
import pickle
import numpy as np

app = FastAPI()
# load model
model = pickle.load(open("model.pkl", "rb"))


@app.get("/")
def home():
    return {"message": "ML API is running"}


@app.get("/feature-importance")
def feature_importance():

    features = ["hours_studied", "sleep_hours", "practice_tests"]
    importance = model.feature_importances_
    print("----- importance-----")
    print(importance)
    result = {}

    for i in range(len(features)):
        result[features[i]] = float(importance[i])
    print("----feature result \n", result)
    return result


@app.post("/predict")
def predict(hours_studied: int, sleep_hours: int, practice_tests: int):

    input_data = np.array([[hours_studied, sleep_hours, practice_tests]])

    prediction = model.predict(input_data)[0]
    probability = model.predict_proba(input_data)[0][1]

    return {
        "prediction": int(prediction),
        "confidence": float(probability)
    }
