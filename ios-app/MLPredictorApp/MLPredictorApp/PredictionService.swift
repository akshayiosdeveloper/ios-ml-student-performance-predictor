//
//  PredictionService.swift
//  MLPredictorApp
//
//  Created by Akshay Kumar on 31/03/26.
//

import Foundation

protocol PredictionServiceProtocol {
    func predict(hours: Int, sleep: Int, tests: Int) async throws -> PredictionResponse
    func fetchFeatureImportance() async throws -> FeatureImportance
}

struct PredictionService: PredictionServiceProtocol {
    private let session: URLSession
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://ios-ml-student-performance-predictor.onrender.com")!
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    func predict(hours: Int, sleep: Int, tests: Int) async throws -> PredictionResponse {
        var components = URLComponents(
            url: baseURL.appending(path: "predict"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "hours_studied", value: String(hours)),
            URLQueryItem(name: "sleep_hours", value: String(sleep)),
            URLQueryItem(name: "practice_tests", value: String(tests))
        ]

        guard let url = components?.url else {
            throw PredictionServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return try await decode(PredictionResponse.self, from: request)
    }

    func fetchFeatureImportance() async throws -> FeatureImportance {
        let request = URLRequest(url: baseURL.appending(path: "feature-importance"))
        return try await decode(FeatureImportance.self, from: request)
    }

    private func decode<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PredictionServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw PredictionServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw PredictionServiceError.emptyResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PredictionServiceError.decodingFailed
        }
    }
}

enum PredictionServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyResponse
    case decodingFailed
    case httpError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The prediction service URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .emptyResponse:
            return "The server returned an empty response."
        case .decodingFailed:
            return "The app could not read the server response."
        case .httpError(let statusCode):
            return "The server returned an error (\(statusCode))."
        }
    }
}
