//
//  PerformanceToolCard.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One tool on the home screen. The legacy `PerformanceCenterOptionView`,
/// moved as it was.
struct PerformanceToolCard: View {

    let tool: PerformanceTool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(tool.imageName, bundle: .performanceKit)
                    .resizable()
                    .frame(width: 50, height: 50)
                Text(tool.title)
                    .font(.title2.bold())
                    .foregroundColor(Color.darkColor)
                Spacer()
            }
            Text(tool.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.premiumColor, lineWidth: 1)
        )
    }
}

#Preview {
    PerformanceToolCard(tool: .workload)
        .padding()
}
