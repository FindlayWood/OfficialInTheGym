//
//  PerformanceHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The legacy `PerformanceCenterView`, moved as it was: the monitor icon, the
/// welcome copy, a card per tool, over a gradient into the premium colour.
/// Redesigning it is the next piece of work, not part of the move.
struct PerformanceHomeScreen: View {

    let viewModel: PerformanceHomeViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Image("monitor_icon", bundle: .performanceKit)
                    .resizable()
                    .frame(width: 100, height: 100)
                Text("Welcome to the performance center. Here you will have access to several performance monitoring tools. Workload, vertical jump, CMJ and more...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                ForEach(viewModel.tools, id: \.self) { tool in
                    Button {
                        viewModel.select(tool)
                    } label: {
                        PerformanceToolCard(tool: tool)
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(
            LinearGradient(colors: [Color(.secondarySystemBackground), Color.premiumColor], startPoint: .top, endPoint: .bottom)
        )
        .navigationTitle("Performance Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PerformanceHomeScreen(viewModel: PerformanceHomeViewModel(currentUserId: "a", athleteId: "a"))
    }
}
