//
//  ContentView.swift
//  MLPredictorApp
//
//  Created by Akshay Kumar on 30/03/26.
//
import SwiftUI
import Charts

struct PredictionResponse: Codable {
    let prediction: Int
    let confidence: Double
}

struct FeatureImportance: Codable {
    let hours_studied: Double
    let sleep_hours: Double
    let practice_tests: Double
}

struct PredictionHistoryItem: Identifiable {
    let id = UUID()
    let hours: Int
    let sleep: Int
    let tests: Int
    let result: String
}
struct FeatureImportanceData: Identifiable {
    let id = UUID()
    let feature: String
    let value: Double
}


struct ContentView: View {
    @State private var hoursStudied = ""
    @State private var sleepHours = ""
    @State private var practiceTests = ""
    @State private var predictionResult = ""
    
    @State private var hoursImportance: Double = 0
    @State private var sleepImportance: Double = 0
    @State private var practiceImportance: Double = 0
    
    @State private var showInsights = false
    @State private var isLoading = false
    
    @State private var confidence: Double = 0.0
    @State private var history: [String] = []
    
    //@State private var history: [PredictionHistoryItem] = []
    
    var chartData: [FeatureImportanceData] {
        [
            FeatureImportanceData(feature: "Hours Studied", value: hoursImportance),
            FeatureImportanceData(feature: "Sleep Hours", value: sleepImportance),
            FeatureImportanceData(feature: "Practice Tests", value: practiceImportance)
        ]
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Title
                Text("Student Performance Predictor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Input Card
                VStack(spacing: 15) {
                    TextField("Hours Studied", text: $hoursStudied)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)

                    TextField("Sleep Hours", text: $sleepHours)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)

                    TextField("Practice Tests", text: $practiceTests)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Predict Button
                Button(action: {
                    hideKeyboard()
                    predictResult()
                    fetchFeatureImportance()
                }) {
                    if isLoading {
                        ProgressView()
                            .padding()
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

                // Prediction Result Card
                if !predictionResult.isEmpty {
                    VStack(spacing: 10) {
                        Text("Prediction Result")
                            .font(.headline)

                        Text(predictionResult)
                            .font(.title2)
                            .fontWeight(.bold)

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

                // Feature Importance
                if showInsights {
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
                            Text("\(item.feature): \(Int(item.value * 100))%")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                // Prediction History
                if !history.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Prediction History")
                            .font(.headline)

                        ForEach(history, id: \.self) { item in
                            Text(item)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
    }
       
    
    
    func predictResult() {
        
        guard let hours = Int(hoursStudied),
              let sleep = Int(sleepHours),
              let tests = Int(practiceTests) else {
            predictionResult = "Invalid input"
            return
        }
        isLoading = true
        // let urlString = "http://127.0.0.1:8000/predict?hours_studied=\(hours)&sleep_hours=\(sleep)&practice_tests=\(tests)"
        // https://ios-ml-student-performance-predictor.onrender.com
        
       // let urlString = "http://192.168.1.6:8000/predict?hours_studied=\(hours)&sleep_hours=\(sleep)&practice_tests=\(tests)"
        
        let urlString = "https://ios-ml-student-performance-predictor.onrender.com/predict?hours_studied=\(hours)&sleep_hours=\(sleep)&practice_tests=\(tests)"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(PredictionResponse.self, from: data)
                
                DispatchQueue.main.async {
                   
                    //predictionResult = result.prediction == 1 ? "Pass" : "Fail"
                    predictionResult = result.prediction == 1
                    ? "Pass (\(Int(result.confidence * 100))%)"
                    : "Fail (\(Int(result.confidence * 100))%)"
                    
                    
                    let historyItem = PredictionHistoryItem(
                        hours: hours,
                        sleep: sleep,
                        tests: tests,
                        result: predictionResult
                    )

                   // history.insert(historyItem, at: 0)
                    // ADD HISTORY HERE
                   // history.append("\(predictionResult) - \(Int(confidence * 100))%")
                    history.append(
                        "Study: \(hoursStudied), Sleep: \(sleepHours), Tests: \(practiceTests) → \(predictionResult)"
                    )
                    isLoading = false
                    showInsights = true
                }
                // Feature importance API called here
                fetchFeatureImportance()
                
            } catch {
                print("Decoding error:", error)
            }
        }
        
        task.resume()
    }
    
    func fetchFeatureImportance() {
        
       // let urlString = "http://192.168.1.6:8000/feature-importance"
        let urlString = "https://ios-ml-student-performance-predictor.onrender.com/feature-importance"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("Error:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(FeatureImportance.self, from: data)
                print(result)
                DispatchQueue.main.async {
                    hoursImportance = result.hours_studied
                    sleepImportance = result.sleep_hours
                    practiceImportance = result.practice_tests
                }
            } catch {
                print("Decode error:", error)
            }
        }
        
        task.resume()
    }
}
func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
}


