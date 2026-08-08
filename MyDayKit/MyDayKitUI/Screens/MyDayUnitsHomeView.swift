//
//  MyDayUnitsHomeView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 24/08/2025.
//

import SwiftUI

struct MyDayUnitsHomeView: View {
    
    @ObservedObject var dayManager: MyDayManager
    @ObservedObject var newExercise: MyDayNewExerciseManager
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var optionSelected: ((ExerciseOptions) -> ())?
    var addedAction: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Rep summary header ─────────────────────────────────────
            repSummaryHeader
            
            Divider()
            
            // ── Options grid ───────────────────────────────────────────
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(ExerciseOptions.allCases) { option in
                        optionCard(option)
                    }
                }
                .padding(16)
            }
            
            Divider()
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addExercise()
            } label: {
                Text("Add Set")
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
    }
    
    // MARK: - Rep Summary Header
    
    private var repSummaryHeader: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(newExercise.exercise.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("Adding a new set")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            // Reps badge
            VStack(spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(newExercise.reps ?? 0)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                    Text((newExercise.reps ?? 0) == 1 ? "rep" : "reps")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
                
                if newExercise.eachSide {
                    Text("each side")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.darkColor)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - Option Card
    
    @ViewBuilder
    private func optionCard(_ option: ExerciseOptions) -> some View {
        let added = newExercise.isOptionAdded(option)
        
        Button {
            optionSelected?(option)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                
                // Title row
                HStack {
                    Text(option.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(added ? Color.darkColor : Color.secondary)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(added ? Color.darkColor : Color(UIColor.tertiarySystemBackground))
                            .frame(width: 24, height: 24)
                        Image(systemName: added ? "checkmark" : "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(added ? Color.white : Color.secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                
                Spacer()
                
                // Value
                Group {
                    if added {
                        addedValueView(for: option)
                    } else {
                        Text("Tap to add")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                }
                .padding(.horizontal, 14)
                
                Spacer()
                
                // Clear button
                if added {
                    Button {
                        newExercise.clear(option)
                    } label: {
                        Text("Clear")
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
                        .frame(height: 29) // keeps card height stable
                        .padding(.bottom, 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 120)
            .background(
                added
                    ? Color.darkColor.opacity(0.06)
                    : Color(UIColor.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        added ? Color.darkColor.opacity(0.25) : Color.clear,
                        lineWidth: 1
                    )
            }
            .animation(.easeInOut(duration: 0.2), value: added)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Added Value Display
    
    @ViewBuilder
    private func addedValueView(for option: ExerciseOptions) -> some View {
        switch option {
        case .weight:
            if let weight = newExercise.weight, let unit = newExercise.weightUnits {
                if unit != .max, unit != .bw {
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(weight.formatted(.number.precision(.fractionLength(0...2))))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.primary)
                        Text(unit.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                } else {
                    Text(unit.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
            }
            
        case .distance:
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                if let distance = newExercise.distance {
                    Text(distance.formatted(.number.precision(.fractionLength(0...2))))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
                if let unit = newExercise.distanceUnits {
                    Text(unit.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
            
        case .time:
            if let time = newExercise.time {
                Text(displayTime(for: time))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .minimumScaleFactor(0.8)
            }
            
        case .tempo:
            if let tempo = newExercise.tempo {
                Text("\(tempo.eccentric)–\(tempo.eccentricHold)–\(tempo.concentric)–\(tempo.concentricHold)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
            }
            
        case .note:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.darkColor)
                Text("Note added")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.primary)
            }
        }
    }
    
    // MARK: - Helpers
    
    func addExercise() {
        if let newCompletion = newExercise.getCompletion() {
            dayManager.addNewCompletion(newCompletion)
            addedAction?()
        }
    }
    
    func displayTime(for totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%dm %02ds", minutes, seconds)
    }
}

#Preview {
    MyDayUnitsHomeView(
        dayManager: MyDayManager(
            saver: PreviewSaver(),
            clipSaver: PreviewMyDaySaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: PreviewLoader(),
            deleter: PreviewMyDayDeleter(),
            wellnessSaver: PreviewMyDaySaver(),
            rpeSaver: PreviewMyDaySaver(),
            workoutSaver: PreviewMyDaySaver()
        ),
        newExercise: .init(exercise: .pressUps)
    )
}

enum ExerciseOptions: String, Identifiable, CaseIterable {
    case weight
    case distance
    case time
    case tempo
    case note
    
    var id: String {
        self.rawValue
    }
    
    var title: String {
        switch self {
        case .weight:
            return "Weight"
        case .distance:
            return "Distance"
        case .time:
            return "Time"
        case .tempo:
            return "Tempo"
        case .note:
            return "Note"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .weight:
            return "dumbbell"
        case .distance:
            return "ruler"
        case .time:
            return "timer"
        case .tempo:
            return "music.note"
        case .note:
            return "pencil"
        }
    }
}
