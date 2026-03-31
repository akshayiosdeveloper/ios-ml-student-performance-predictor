//
//  PredictionModels.swift
//  MLPredictorApp
//
//  Created by Akshay Kumar on 31/03/26.
//

import Foundation

struct PredictionResponse: Codable, Sendable {
    let prediction: Int
    let confidence: Double
}

struct FeatureImportance: Codable, Sendable {
    let hoursStudied: Double
    let sleepHours: Double
    let practiceTests: Double

    enum CodingKeys: String, CodingKey {
        case hoursStudied = "hours_studied"
        case sleepHours = "sleep_hours"
        case practiceTests = "practice_tests"
    }
}

struct PredictionHistoryItem: Identifiable, Equatable, Sendable {
    let id = UUID()
    let hours: Int
    let sleep: Int
    let tests: Int
    let prediction: String
    let confidence: Double
}

struct FeatureImportanceData: Identifiable, Equatable, Sendable {
    let id = UUID()
    let feature: String
    let value: Double
}
