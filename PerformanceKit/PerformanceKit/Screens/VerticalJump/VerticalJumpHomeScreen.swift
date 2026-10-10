//
//  VerticalJumpHomeScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The legacy `VerticalJumpHomeView`, moved as it was: the jump icon, the best
/// jump, then Record New Jump, My Jumps and Help.
struct VerticalJumpHomeScreen: View {

    @ObservedObject var viewModel: VerticalJumpHomeViewModel

    var body: some View {
        List {
            HStack {
                Spacer()
                VStack {
                    Image("jump_icon", bundle: .performanceKit)
                        .resizable()
                        .frame(width: 60, height: 60)
                    Text("Welcome to the vertical jump measurement. Here you can measure the height of your vertical jump.")
                        .font(.body.weight(.medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .listRowBackground(Color.clear)

            Section {
                if viewModel.isLoading {
                    ProgressView()
                } else if let max = viewModel.max {
                    VerticalJumpRow(jump: max, measurement: .cm)
                } else {
                    Text("No Jumps recorded.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Max Jump Height")
            }

            if viewModel.canRecord {
                Section {
                    Button {
                        viewModel.recordNewJump()
                    } label: {
                        Text("Record New Jump")
                    }
                    .disabled(viewModel.isLoading)
                }
            }

            Section {
                Button {
                    viewModel.previousJumps()
                } label: {
                    Text("My Jumps")
                }
            }

            Section {
                Button {
                    viewModel.help()
                } label: {
                    Text("Help")
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
