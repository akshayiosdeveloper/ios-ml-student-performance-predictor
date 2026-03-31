//
//  ImportanceBar.swift
//  MLPredictorApp
//
//  Created by Akshay Kumar on 31/03/26.
//

import SwiftUI

struct ImportanceBar: View {
    var title: String
    var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(title) - \(Int(value * 100))%")
                .font(.subheadline)
                .fontWeight(.medium)

            ProgressView(value: value)
        }
    }
}
