//
//  WorkoutSessionSummaryScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 30/06/2026.
//

import SwiftUI

struct WorkoutSessionSummaryScreen: View {

    @ObservedObject var manager: WorkoutSessionManager
    let endedAt: Date
    var onComplete: (() -> Void)?

    @State private var selectedRPE: Int?
    @State private var notes: String = ""
    @FocusState private var notesFocused: Bool

    private var durationSeconds: Int {
        Int(endedAt.timeIntervalSince(manager.startedAt))
    }

    private var durationMinutes: Double {
        endedAt.timeIntervalSince(manager.startedAt) / 60.0
    }

    private var workload: Double? {
        guard let rpe = selectedRPE else { return nil }
        return durationMinutes * Double(rpe)
    }

    private var formattedDuration: String {
        let h = durationSeconds / 3600
        let m = (durationSeconds % 3600) / 60
        let s = durationSeconds % 60
        return h > 0
            ? String(format: "%d:%02d", h, m)
            : String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                statsRow
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                Divider()

                rpeSection
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                if let workload {
                    workloadRow(workload)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Divider()

                notesSection
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            completeButton
        }
        .animation(.easeInOut(duration: 0.25), value: selectedRPE != nil)
        .contentShape(Rectangle())
        .onTapGesture { notesFocused = false }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DURATION")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                Text(formattedDuration)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.primary)
            }

            Spacer()

            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(width: 1, height: 44)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("SETS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(manager.totalSetsLogged)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("/ \(manager.totalSetsTargeted)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
    }

    // MARK: - RPE Section

    private var rpeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Session RPE")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Rate your overall effort")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if let avg = manager.averageExerciseRPE {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("AVG EXERCISE")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .tracking(1.0)
                        Text(String(format: "%.1f", avg))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(rpeColor(Int(avg.rounded())))
                    }
                }
            }

            LazyVGrid(
                columns: (0..<5).map { _ in GridItem(.flexible(), spacing: 8) },
                spacing: 8
            ) {
                ForEach(1...10, id: \.self) { value in
                    let selected = selectedRPE == value
                    let color = rpeColor(value)
                    Button {
                        selectedRPE = value
                    } label: {
                        Text("\(value)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(selected ? .white : color)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selected ? color : Color(UIColor.secondarySystemBackground))
                            )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(selected ? 1.05 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: selected)
                }
            }
        }
    }

    // MARK: - Workload Row

    private func workloadRow(_ value: Double) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("WORKLOAD")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                Text("Duration × RPE")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Text(String(format: "%.0f", value))
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: value)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notes")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)

            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Add any notes about this workout...")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(UIColor.placeholderText))
                        .padding(.leading, 5)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $notes)
                    .focused($notesFocused)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 100)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        Button {
            manager.finishSession(rpe: selectedRPE, notes: notes.isEmpty ? nil : notes)
            onComplete?()
        } label: {
            Text("Complete Workout")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.darkColor)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - RPE Color

    private func rpeColor(_ value: Int) -> Color {
        switch value {
        case 1:  return Color(red: 0.13, green: 0.75, blue: 0.35)
        case 2:  return Color(red: 0.35, green: 0.78, blue: 0.20)
        case 3:  return Color(red: 0.58, green: 0.80, blue: 0.10)
        case 4:  return Color(red: 0.80, green: 0.80, blue: 0.00)
        case 5:  return Color(red: 0.95, green: 0.70, blue: 0.00)
        case 6:  return Color(red: 1.00, green: 0.55, blue: 0.00)
        case 7:  return Color(red: 1.00, green: 0.38, blue: 0.00)
        case 8:  return Color(red: 0.95, green: 0.20, blue: 0.00)
        case 9:  return Color(red: 0.82, green: 0.08, blue: 0.00)
        case 10: return Color(red: 0.65, green: 0.00, blue: 0.00)
        default: return Color.gray
        }
    }
}
