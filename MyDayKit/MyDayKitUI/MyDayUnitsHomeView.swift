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
    
    var optionSelected: ((ExerciseOptions) -> ())?
    
    var addedAction:(() -> ())?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(ExerciseOptions.allCases) { option in
                        Button {
                            optionSelected?(option)
                        } label: {
                            let added = newExercise.isOptionAdded(option)
                            HStack {
                                Text(option.title)
                                    .font(.headline)
                                    .foregroundStyle(Color.black.opacity(added ? 1 : 0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                            
                                if added {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                        .padding(.top)
                                    
                                    Button {
                                        
                                    } label: {
                                        Text("Clear")
                                    }
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
}
