# iOS ML Student Performance Predictor

An iOS app that predicts whether a student will pass or fail using a Machine Learning model served via FastAPI backend.

![Swift](https://img.shields.io/badge/Swift-5-orange)
![Python](https://img.shields.io/badge/Python-FastAPI-blue)
![Machine Learning](https://img.shields.io/badge/ML-Scikit--Learn-green)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey)

---

## Project Overview

This project demonstrates how an iOS application can integrate with a Machine Learning model hosted on a backend API.

The app predicts student performance based on:

- Hours Studied
- Sleep Hours
- Practice Tests

The ML model is trained using **Scikit-learn** and served using **FastAPI**.  
The iOS app is built using **SwiftUI** and communicates with the backend through REST APIs.

## Demo Video

This video shows:

- Entering student study details
- Sending request to ML backend
- Receiving prediction and confidence
- Visualizing feature importance
- Viewing prediction history

https://github.com/akshayiosdeveloper/ios-ml-student-performance-predictor/blob/master/demo-video_sample.mp4

## App Screenshots

<p align="center">
  <img src="screenshots/home_screen.png" width="260" height="540"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="screenshots/pass_student_prediction.png" width="260" height="540"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="screenshots/fail_student_prediction.png" width="260" height="540"/>
</p>

<p align="center">
  <img src="screenshots/pass_student_chart.png" width="260" height="540"/>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="screenshots/fail_student_chart.png" width="260" height="540"/>
</p>

## Architecture

iOS App (SwiftUI)
↓
REST API
↓
FastAPI Backend
↓
Scikit-learn ML Model

---

## Tech Stack

Frontend:

- SwiftUI
- iOS

Backend:

- FastAPI
- Python

Machine Learning:

- Scikit-learn
- NumPy
- Pandas

Deployment:

- Render

---

## Features

- Predict student performance
- Feature importance visualization
- Prediction history
- REST API integration
- Deployed backend
- Clean SwiftUI UI

---

## Future Improvements

- Add more ML models
- Improve dataset
- Add authentication
- Deploy iOS app to App Store

## Author

Akshay Kumar
iOS Developer transitioning into AI Engineering
