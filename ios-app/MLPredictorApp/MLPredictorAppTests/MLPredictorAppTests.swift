//
//  MLPredictorAppTests.swift
//  MLPredictorAppTests
//
//  Created by Akshay Kumar on 30/03/26.
//

import Testing
@testable import MLPredictorApp

@MainActor
struct MLPredictorAppTests {
    @Test func emptyInputShowsValidationError() async throws {
        let service = MockPredictionService()
        let viewModel = PredictionViewModel(service: service)

        await viewModel.predict()

        #expect(viewModel.errorMessage == "Please fill in all fields.")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.predictionResult.isEmpty)
        #expect(service.predictCallCount == 0)
        #expect(service.featureImportanceCallCount == 0)
    }

    @Test func nonNumericInputShowsValidationError() async throws {
        let service = MockPredictionService()
        let viewModel = PredictionViewModel(service: service)
        viewModel.hoursStudied = "ten"
        viewModel.sleepHours = "8"
        viewModel.practiceTests = "4"

        await viewModel.predict()

        #expect(viewModel.errorMessage == "Please enter valid numbers only.")
        #expect(viewModel.isLoading == false)
        #expect(service.predictCallCount == 0)
    }

    @Test func successfulPredictionUpdatesAllStateOnce() async throws {
        let service = MockPredictionService(
            predictionResult: .success(PredictionResponse(prediction: 1, confidence: 0.86)),
            featureImportanceResult: .success(
                FeatureImportance(hoursStudied: 0.5, sleepHours: 0.3, practiceTests: 0.2)
            )
        )
        let viewModel = PredictionViewModel(service: service)
        viewModel.hoursStudied = "10"
        viewModel.sleepHours = "8"
        viewModel.practiceTests = "4"

        await viewModel.predict()

        #expect(viewModel.predictionResult == "Pass")
        #expect(viewModel.confidence == 0.86)
        #expect(viewModel.history.count == 1)
        #expect(viewModel.history.first?.hours == 10)
        #expect(viewModel.history.first?.prediction == "Pass")
        #expect(viewModel.showInsights == true)
        #expect(viewModel.featureImportances.count == 3)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(service.predictCallCount == 1)
        #expect(service.featureImportanceCallCount == 1)
    }

    @Test func predictionFailureClearsLoadingAndShowsError() async throws {
        let service = MockPredictionService(
            predictionResult: .failure(PredictionServiceError.invalidResponse)
        )
        let viewModel = PredictionViewModel(service: service)
        viewModel.hoursStudied = "10"
        viewModel.sleepHours = "8"
        viewModel.practiceTests = "4"

        await viewModel.predict()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.predictionResult.isEmpty)
        #expect(viewModel.confidence == 0)
        #expect(viewModel.showInsights == false)
        #expect(viewModel.errorMessage == "The server returned an invalid response.")
        #expect(service.predictCallCount == 1)
        #expect(service.featureImportanceCallCount == 0)
    }

    @Test func featureImportanceFailureKeepsPredictionAndShowsHelpfulError() async throws {
        let service = MockPredictionService(
            predictionResult: .success(PredictionResponse(prediction: 0, confidence: 0.42)),
            featureImportanceResult: .failure(PredictionServiceError.emptyResponse)
        )
        let viewModel = PredictionViewModel(service: service)
        viewModel.hoursStudied = "5"
        viewModel.sleepHours = "6"
        viewModel.practiceTests = "2"

        await viewModel.predict()

        #expect(viewModel.predictionResult == "Fail")
        #expect(viewModel.confidence == 0.42)
        #expect(viewModel.history.count == 1)
        #expect(viewModel.featureImportances.isEmpty)
        #expect(viewModel.showInsights == false)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == "Prediction succeeded, but model insights could not be loaded.")
        #expect(service.predictCallCount == 1)
        #expect(service.featureImportanceCallCount == 1)
    }

    @Test func predictionLabelFormattingMatchesExpectedValues() async throws {
        #expect(PredictionViewModel.predictionLabel(for: 1) == "Pass")
        #expect(PredictionViewModel.predictionLabel(for: 0) == "Fail")
    }
}

private final class MockPredictionService: PredictionServiceProtocol {
    private(set) var predictCallCount = 0
    private(set) var featureImportanceCallCount = 0

    var predictionResult: Result<PredictionResponse, Error>
    var featureImportanceResult: Result<FeatureImportance, Error>

    init(
        predictionResult: Result<PredictionResponse, Error> = .success(
            PredictionResponse(prediction: 1, confidence: 0.9)
        ),
        featureImportanceResult: Result<FeatureImportance, Error> = .success(
            FeatureImportance(hoursStudied: 0.4, sleepHours: 0.35, practiceTests: 0.25)
        )
    ) {
        self.predictionResult = predictionResult
        self.featureImportanceResult = featureImportanceResult
    }

    func predict(hours: Int, sleep: Int, tests: Int) async throws -> PredictionResponse {
        predictCallCount += 1
        return try predictionResult.get()
    }

    func fetchFeatureImportance() async throws -> FeatureImportance {
        featureImportanceCallCount += 1
        return try featureImportanceResult.get()
    }
}
