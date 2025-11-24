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
    
    let columns: [GridItem] = Array(repeating: .init(), count: 2)
    
    
    var optionSelected: ((ExerciseOptions) -> ())?
    
    var addedAction:(() -> ())?
    
    var body: some View {
        VStack {
            VStack {
                Text(newExercise.exercise.name)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .padding(.bottom)
                HStack(alignment: .lastTextBaseline) {
                    Text("\(newExercise.reps ?? 0) \(newExercise.eachSide ? "(e)" : "")")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("reps")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.primary.opacity(0.5))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                Color
                    .white
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 4)
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(ExerciseOptions.allCases) { option in
                        let added = newExercise.isOptionAdded(option)
                        VStack {
                            Text(option.title)
                                .font(.headline)
                                .foregroundStyle(Color.black.opacity(added ? 1 : 0.5))
                            
                            Spacer()
                            
                            if added {
                                switch option {
                                case .weight:
                                    if let weight = newExercise.weight, let unit = newExercise.weightUnits {
                                        if unit != .max, unit != .bw {
                                            Text("\(weight.formatted(.number.precision(.fractionLength(0...6)))) \(unit.rawValue)")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundStyle(Color.black)
                                        } else {
                                            Text("\(unit.rawValue)")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundStyle(Color.black)
                                        }
                                    }
                                case .distance:
                                    HStack {
                                        if let distance = newExercise.distance {
                                            Text("\(distance.formatted(.number.precision(.fractionLength(0...6))))")
                                                .font(.system(size: 20, weight: .semibold))
                                        }
                                        if let distanceUnit = newExercise.distanceUnits {
                                            Text("\(distanceUnit.rawValue)")
                                                .font(.system(size: 16, weight: .medium))
                                        }
                                    }
                                case .time:
                                    if let time = newExercise.time {
                                        Text(displayTime(for: time))
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(Color.black)
                                    }
                                case .tempo:
                                    if let tempo = newExercise.tempo {
                                        Text("\(tempo.eccentric)-\(tempo.eccentricHold)-\(tempo.concentric)-\(tempo.concentricHold)")
                                            .font(.system(size: 20, weight: .semibold))
                                    }
                                case .note:
                                    Text("Added")
                                        .font(.system(size: 20, weight: .semibold))
                                }
                                
                                Spacer()
                            }
                            
                            
                            if added {
                                Button {
                                    newExercise.clear(option)
                                } label: {
                                    Text("Clear")
                                }
                            } else {
                                Button {
                                    optionSelected?(option)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                }
                                
                            }
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background {
                            Color
                                .white
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 4)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            optionSelected?(option)
                        }
                    }
                }
                .padding()
            }
            
            Button {
                addExercise()
            } label: {
                Text("Add")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        Color
                            .blue
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
            }
            .padding()
        }
    }
    
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
    MyDayUnitsHomeView(dayManager: MyDayManager(saver: PreviewSaver(), loader: PreviewLoader()), newExercise: .init(exercise: .pressUps))
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
