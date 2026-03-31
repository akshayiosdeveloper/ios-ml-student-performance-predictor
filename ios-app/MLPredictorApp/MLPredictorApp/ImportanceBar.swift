//
//  ImportanceBar.swift
//  MLPredictorApp
//
//  Created by Akshay Kumar on 31/03/26.
//
import SwiftUI

//struct ImportanceBar: View {
//    var title: String
//    var value: Double   // value between 0 and 1
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(title)
//                .font(.subheadline)
//            
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    
//                    // Background bar
//                    Rectangle()
//                        .frame(height: 10)
//                        .opacity(0.2)
//                        .cornerRadius(5)
//                    
//                    // Filled bar
//                    Rectangle()
//                        .frame(width: geometry.size.width * value, height: 10)
//                        .cornerRadius(5)
//                }
//            }
//            .frame(height: 10)
//            
//            Text("\(Int(value * 100))%")
//                .font(.caption)
//        }
//    }
//}

struct ImportanceBar: View {
    var title: String
    var value: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title) - \(Int(value * 100))%")

            ProgressView(value: value)
        }
    }
}
