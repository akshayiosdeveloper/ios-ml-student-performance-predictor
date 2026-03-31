//
//  ContentView.swift
//  MLPredictorApp
//
//  Created by Akshay Kumar on 30/03/26.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var viewModel = PredictionViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Student Performance Predictor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                PredictionInputSection(
                    hoursStudied: $viewModel.hoursStudied,
                    sleepHours: $viewModel.sleepHours,
                    practiceTests: $viewModel.practiceTests
                )

                Button {
                    hideKeyboard()
                    Task {
                        await viewModel.predict()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Predict Performance")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .accessibilityIdentifier("predictButton")

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("errorMessage")
                }

                if !viewModel.predictionResult.isEmpty {
                    PredictionResultSection(
                        predictionResult: viewModel.predictionResult,
                        confidence: viewModel.confidence
                    )
                }

                if viewModel.showInsights {
                    ModelInsightsSection(chartData: viewModel.featureImportances)
                }

                if !viewModel.history.isEmpty {
                    PredictionHistorySection(history: viewModel.history)
                }
            }
            .padding()
        }
    }
}

private struct PredictionInputSection: View {
    @Binding var hoursStudied: String
    @Binding var sleepHours: String
    @Binding var practiceTests: String

    var body: some View {
        VStack(spacing: 15) {
            TextField("Hours Studied", text: $hoursStudied)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            TextField("Sleep Hours", text: $sleepHours)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            TextField("Practice Tests", text: $practiceTests)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct PredictionResultSection: View {
    let predictionResult: String
    let confidence: Double

    var body: some View {
        VStack(spacing: 10) {
            Text("Prediction Result")
                .font(.headline)

            Text(predictionResult)
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityIdentifier("predictionResult")

            ProgressView(value: confidence)
                .padding(.horizontal)

            Text("Confidence: \(Int(confidence * 100))%")
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct ModelInsightsSection: View {
    let chartData: [FeatureImportanceData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Model Insights")
                .font(.headline)

            Chart(chartData) { item in
                BarMark(
                    x: .value("Feature", item.feature),
                    y: .value("Importance", item.value)
                )
            }
            .frame(height: 220)

            ForEach(chartData) { item in
                ImportanceBar(title: item.feature, value: item.value)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct PredictionHistorySection: View {
    let history: [PredictionHistoryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Prediction History")
                .font(.headline)

            ForEach(history) { item in
                Text(
                    "Study: \(item.hours), Sleep: \(item.sleep), Tests: \(item.tests) → \(item.prediction) (\(Int(item.confidence * 100))%)"
                )
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
        }
    }
}

private func hideKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}
