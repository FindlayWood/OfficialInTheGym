//
//  MyDayWorkoutSessionLogSetSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct MyDayWorkoutSessionLogSetSheet: View {

    let exercise: WorkoutExerciseModel
    let setNumber: Int
    let targetSet: WorkoutSetModel?
    let userId: String
    var onLog: ((WorkoutSetLog) -> Void)?

    @State private var repsInput: String
    @State private var weightInput: String
    @State private var timeInput: String
    @State private var distanceInput: String

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: InputField?

    private enum InputField { case reps, weight, time, distance }

    init(
        exercise: WorkoutExerciseModel,
        setNumber: Int,
        targetSet: WorkoutSetModel?,
        editingLog: WorkoutSetLog? = nil,
        userId: String,
        onLog: ((WorkoutSetLog) -> Void)? = nil
    ) {
        self.exercise = exercise
        self.setNumber = setNumber
        self.targetSet = targetSet
        self.userId = userId
        self.onLog = onLog

        let source = editingLog
        let reps = source?.reps.map { "\($0)" } ?? targetSet?.reps.map { "\($0)" } ?? ""
        let weight = source?.weight.map { formatDouble($0) } ?? targetSet?.weight.map { formatDouble($0) } ?? ""
        let time = source?.time.map { "\($0)" } ?? targetSet?.time.map { "\($0)" } ?? ""
        let distance = source?.distance.map { formatDouble($0) } ?? targetSet?.distance.map { formatDouble($0) } ?? ""

        _repsInput = State(initialValue: reps)
        _weightInput = State(initialValue: weight)
        _timeInput = State(initialValue: time)
        _distanceInput = State(initialValue: distance)
    }

    private var isTimePrimary: Bool { targetSet?.reps == nil && targetSet?.time != nil }
    private var isDistancePrimary: Bool { targetSet?.reps == nil && targetSet?.distance != nil && targetSet?.time == nil }

    private var canLog: Bool {
        if isTimePrimary { return !timeInput.isEmpty }
        if isDistancePrimary { return !distanceInput.isEmpty }
        return !repsInput.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHandle

            titleBlock
                .padding(.bottom, 24)

            if let target = targetSet {
                targetReference(target)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }

            inputFields
                .padding(.horizontal, 20)

            Spacer()

            logButton
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Sheet Handle

    private var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(UIColor.tertiaryLabel))
            .frame(width: 40, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 20)
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(spacing: 4) {
            Text(exercise.exerciseId)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text("Log Set \(setNumber)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Target Reference

    private func targetReference(_ target: WorkoutSetModel) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "target")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.secondary)
            Text("Target:")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            targetSummaryText(target)
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func targetSummaryText(_ target: WorkoutSetModel) -> some View {
        HStack(spacing: 6) {
            if let reps = target.reps {
                Text("\(reps) reps")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
            if let weight = target.weight, let unit = target.weightUnit {
                Text("× \(formatDouble(weight)) \(unit.rawValue)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
            if let time = target.time {
                let m = time / 60; let s = time % 60
                Text(m > 0 ? "\(m)m \(s)s" : "\(s)s")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
            if let dist = target.distance, let unit = target.distanceUnit {
                Text("\(formatDouble(dist)) \(unit.rawValue)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
        }
    }

    // MARK: - Input Fields

    @ViewBuilder
    private var inputFields: some View {
        VStack(spacing: 12) {
            if isTimePrimary {
                numericField(label: "Time (seconds)", binding: $timeInput, placeholder: "0", field: .time)
            } else if isDistancePrimary {
                let unit = targetSet?.distanceUnit?.rawValue ?? "m"
                numericField(label: "Distance (\(unit))", binding: $distanceInput, placeholder: "0", field: .distance)
            } else {
                numericField(label: "Reps", binding: $repsInput, placeholder: "0", field: .reps)
            }

            numericField(
                label: "Weight (\(targetSet?.weightUnit?.rawValue ?? "kg"))",
                binding: $weightInput,
                placeholder: "Optional",
                field: .weight
            )
        }
    }

    private func numericField(label: String, binding: Binding<String>, placeholder: String, field: InputField) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            TextField(placeholder, text: binding)
                .keyboardType(.decimalPad)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .focused($focused, equals: field)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    focused == field ? Color.darkColor.opacity(0.5) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                )
        }
    }

    // MARK: - Log Button

    private var logButton: some View {
        Button {
            commitLog()
        } label: {
            Text("Log Set \(setNumber)")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(canLog ? Color.white : Color.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(canLog ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                )
        }
        .disabled(!canLog)
        .animation(.easeInOut(duration: 0.15), value: canLog)
    }

    // MARK: - Commit

    private func commitLog() {
        let log = WorkoutSetLog(
            id: UUID().uuidString,
            exerciseId: exercise.exerciseId,
            userId: userId,
            workoutSessionId: nil,
            orderIndex: setNumber - 1,
            reps: Int(repsInput),
            weight: Double(weightInput),
            weightUnit: targetSet?.weightUnit,
            distance: Double(distanceInput),
            distanceUnit: targetSet?.distanceUnit,
            time: Int(timeInput),
            tempo: nil,
            note: nil,
            eachSide: targetSet?.eachSide,
            completedAt: Date()
        )
        onLog?(log)
    }
}

// MARK: - Helpers

private func formatDouble(_ v: Double) -> String {
    v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))" : "\(v)"
}
