//
//  PredictionViewModel.swift
//  MLPredictorApp
//
//  Created by Akshay Kumar on 31/03/26.
//

import Foundation
import Combine

@MainActor
final class PredictionViewModel: ObservableObject {
    @Published var hoursStudied = ""
    @Published var sleepHours = ""
    @Published var practiceTests = ""

    @Published private(set) var predictionResult = ""
    @Published private(set) var confidence = 0.0
    @Published private(set) var featureImportances: [FeatureImportanceData] = []
    @Published private(set) var history: [PredictionHistoryItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var showInsights = false

    private let service: PredictionServiceProtocol

    init(service: PredictionServiceProtocol? = nil) {
        self.service = service ?? PredictionService()
    }

    func predict() async {
        errorMessage = nil
        showInsights = false

        let inputs: PredictionInput
        do {
            inputs = try validatedInput()
        } catch let error as PredictionInputError {
            resetForValidationFailure(message: error.localizedDescription)
            return
        } catch {
            resetForValidationFailure(message: "Invalid input.")
            return
        }

        isLoading = true

        do {
            let prediction = try await service.predict(
                hours: inputs.hours,
                sleep: inputs.sleep,
                tests: inputs.tests
            )

            predictionResult = Self.predictionLabel(for: prediction.prediction)
            confidence = prediction.confidence

            history.insert(
                PredictionHistoryItem(
                    hours: inputs.hours,
                    sleep: inputs.sleep,
                    tests: inputs.tests,
                    prediction: predictionResult,
                    confidence: prediction.confidence
                ),
                at: 0
            )

            do {
                let featureImportance = try await service.fetchFeatureImportance()
                featureImportances = [
                    FeatureImportanceData(feature: "Hours Studied", value: featureImportance.hoursStudied),
                    FeatureImportanceData(feature: "Sleep Hours", value: featureImportance.sleepHours),
                    FeatureImportanceData(feature: "Practice Tests", value: featureImportance.practiceTests)
                ]
                showInsights = true
            } catch {
                featureImportances = []
                errorMessage = "Prediction succeeded, but model insights could not be loaded."
            }
        } catch {
            predictionResult = ""
            confidence = 0
            featureImportances = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    static func predictionLabel(for value: Int) -> String {
        value == 1 ? "Pass" : "Fail"
    }

    private func validatedInput() throws -> PredictionInput {
        guard !hoursStudied.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !sleepHours.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !practiceTests.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PredictionInputError.emptyFields
        }

        guard let hours = Int(hoursStudied),
              let sleep = Int(sleepHours),
              let tests = Int(practiceTests) else {
            throw PredictionInputError.nonNumeric
        }

        return PredictionInput(hours: hours, sleep: sleep, tests: tests)
    }

    private func resetForValidationFailure(message: String) {
        predictionResult = ""
        confidence = 0
        featureImportances = []
        errorMessage = message
        isLoading = false
        showInsights = false
    }
}

private struct PredictionInput {
    let hours: Int
    let sleep: Int
    let tests: Int
}

private enum PredictionInputError: LocalizedError {
    case emptyFields
    case nonNumeric

    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Please fill in all fields."
        case .nonNumeric:
            return "Please enter valid numbers only."
        }
    }
}
