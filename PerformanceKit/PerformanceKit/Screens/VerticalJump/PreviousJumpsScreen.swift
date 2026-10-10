//
//  PreviousJumpsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The legacy `PreviousJumpsView`, moved as it was: sort by date or height,
/// convert to cm or inches, then every jump.
struct PreviousJumpsScreen: View {

    @ObservedObject var viewModel: PreviousJumpsViewModel

    var body: some View {
        List {
            Section {
                HStack(alignment: .bottom) {
                    VStack {
                        Text("SORT BY")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        HStack {
                            Button {
                                withAnimation { viewModel.sortByDate(true) }
                            } label: {
                                Image(systemName: viewModel.sortedByDate ? "calendar.circle.fill" : "calendar.circle")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color.darkColor)
                            }
                            .buttonStyle(.borderless)
                            Button {
                                withAnimation { viewModel.sortByDate(false) }
                            } label: {
                                Image(systemName: viewModel.sortedByDate ? "number.circle" : "number.circle.fill")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color.darkColor)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    Spacer()
                    VStack {
                        Text("CONVERT TO")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Picker("Select Measurement", selection: $viewModel.measurement) {
                            ForEach(JumpMeasurement.allCases, id: \.self) {
                                Text($0.title)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 200)
                        .frame(height: 30)
                    }
                }
            }
            .listRowBackground(Color.clear)

            Section {
                ForEach(viewModel.sortedJumps, id: \.time) { jump in
                    VerticalJumpRow(jump: jump, measurement: viewModel.measurement)
                }
            } header: {
                Text("Previous Jumps")
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle("My Vertical Jumps")
    }
}
