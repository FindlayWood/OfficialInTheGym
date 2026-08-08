//
//  MyDayWorkoutBuilderUnitsScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/05/2026.
//

import SwiftUI

struct MyDayWorkoutBuilderUnitsScreen: View {
    
    @ObservedObject var exercise: WorkoutExerciseBuilderManager
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var optionSelected: ((ExerciseOptions) -> ())?
    var continueAction: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Set scroll ─────────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(exercise.sets.indices, id: \.self) { index in
                        SetSummaryPill(set: exercise.sets[index], index: index)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .padding(.vertical, 12)
            
            Divider()
            
            // ── Options grid ───────────────────────────────────────────
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(ExerciseOptions.allCases) { option in
                        OptionCard(
                            option: option,
                            sets: exercise.sets,
                            optionSelected: { optionSelected?(option) },
                            clearAction: {
                                exercise.sets.forEach { $0.clear(option) }
                            }
                        )
                    }
                }
                .padding(16)
            }
            
            Divider()
            
            // ── Continue ───────────────────────────────────────────────
            Button {
                continueAction?()
            } label: {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.darkColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(exercise.exercise.name)
    }
}

// MARK: - Set Summary Pill

private struct SetSummaryPill: View {
    @ObservedObject var set: WorkoutExerciseSetManager
    let index: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Set \(index + 1)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.primary)
            
            if let reps = set.reps {
                Text("\(reps) \(reps == 1 ? "rep" : "reps")")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.secondary)
            } else {
                Text("No reps")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
        .frame(width: 72, height: 52)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Option Card

private struct OptionCard: View {
    @ObservedObject private var observer: SetsObserver
    let option: ExerciseOptions
    let sets: [WorkoutExerciseSetManager]
    var optionSelected: (() -> ())?
    var clearAction: (() -> ())?

    init(
        option: ExerciseOptions,
        sets: [WorkoutExerciseSetManager],
        optionSelected: (() -> ())? = nil,
        clearAction: (() -> ())? = nil
    ) {
        self.option = option
        self.sets = sets
        self.optionSelected = optionSelected
        self.clearAction = clearAction
        self._observer = ObservedObject(wrappedValue: SetsObserver(sets: sets))
    }
    
    private var status: OptionStatus {
        switch option {
        case .weight:
            return resolveStatus(sets.map { s in
                guard let w = s.weight, let u = s.weightUnits else { return nil }
                return u == .max || u == .bw ? u.rawValue : "\(w.formatted(.number.precision(.fractionLength(0...2)))) \(u.rawValue)"
            })
        case .distance:
            return resolveStatus(sets.map { s in
                guard let d = s.distance, let u = s.distanceUnits else { return nil }
                return "\(d.formatted(.number.precision(.fractionLength(0...2)))) \(u.rawValue)"
            })
        case .time:
            return resolveStatus(sets.map { s in
                guard let t = s.time else { return nil }
                return displayTime(for: t)
            })
        case .tempo:
            return resolveStatus(sets.map { s in
                guard let t = s.tempo else { return nil }
                return "\(t.eccentric)–\(t.eccentricHold)–\(t.concentric)–\(t.concentricHold)"
            })
        case .note:
            return resolveStatus(sets.map { s in s.note != nil ? "Note" : nil })
        }
    }
    
    var body: some View {
        Button {
            optionSelected?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                
                // ── Title row ──────────────────────────────────────────
                HStack {
                    Text(option.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(status.hasAny ? Color.darkColor : Color.secondary)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(status.hasAny ? Color.darkColor : Color(UIColor.tertiarySystemBackground))
                            .frame(width: 24, height: 24)
                        Image(systemName: status.hasAny ? "checkmark" : "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(status.hasAny ? Color.white : Color.secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                
                Spacer()
                
                // ── Status value ───────────────────────────────────────
                statusValueView
                    .padding(.horizontal, 14)
                
                Spacer()
                
                // ── Clear button ───────────────────────────────────────
                if status.hasAny {
                    Button {
                        clearAction?()
                    } label: {
                        Text("Clear all")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                } else {
                    Spacer()
                        .frame(height: 29)
                        .padding(.bottom, 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 120)
            .background(status.hasAny ? Color.darkColor.opacity(0.06) : Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(status.hasAny ? Color.darkColor.opacity(0.25) : Color.clear, lineWidth: 1)
            }
            .animation(.easeInOut(duration: 0.2), value: status.hasAny)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var statusValueView: some View {
        switch status {
        case .none:
            Text("Tap to add")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color(UIColor.tertiaryLabel))
            
        case .allSame(let value):
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
        case .allSet:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.darkColor)
                Text("All sets vary")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            
        case .partial:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.orange)
                Text("Some sets missing")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func resolveStatus(_ values: [String?]) -> OptionStatus {
        let filled = values.compactMap { $0 }
        if filled.isEmpty { return .none }
        if filled.count < values.count { return .partial }
        let allSame = filled.allSatisfy { $0 == filled[0] }
        return allSame ? .allSame(filled[0]) : .allSet
    }
    
    private func displayTime(for totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%dm %02ds", minutes, seconds)
    }
}

// MARK: - Option Status

private enum OptionStatus: Equatable {
    case none
    case allSame(String)
    case allSet
    case partial
    
    var hasAny: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
}

#Preview {
    let exercise = WorkoutExerciseBuilderManager(exercise: .pressUps)
    exercise.addSets(4)
    return MyDayWorkoutBuilderUnitsScreen(exercise: exercise)
}

import Combine

private class SetsObserver: ObservableObject {
    private var cancellables: [AnyCancellable] = []

    init(sets: [WorkoutExerciseSetManager]) {
        sets.forEach { set in
            set.objectWillChange
                .sink { [weak self] _ in self?.objectWillChange.send() }
                .store(in: &cancellables)
        }
    }
}
