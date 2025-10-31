//
//  MyDayKitRouter.swift
//  MyDayKit
//
//  Created by Findlay Wood on 06/08/2025.
//

import Combine
import SwiftUI

enum MyDayRoutes: Hashable {
    case root
    case add
    case reps(MyDayNewExerciseManager)
    case units(MyDayNewExerciseManager)
    case weight(MyDayNewExerciseManager)
    case distance(MyDayNewExerciseManager)
    case time(MyDayNewExerciseManager)
    case tempo(MyDayNewExerciseManager)
}

enum MyDaySheets: Identifiable {
    var id: String {
        switch self {
        case .add:
            return "add"
        }
    }
    
    case add
}

enum MyDayFullScreenCover: Identifiable {
    var id: String {
        switch self {
        case .recordClip:
            return "recordClip"
        }
    }
    case recordClip
}

public class MyDayKitRouter: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var presentedSheet: MyDaySheets?
    @Published var fullScreenCover: MyDayFullScreenCover?
    
    let exerciseManager: ExerciseManager
    let dayManager: MyDayManager
    
    public init(exerciseManager: ExerciseManager, dayManager: MyDayManager) {
        self.exerciseManager = exerciseManager
        self.dayManager = dayManager
    }
    
    @ViewBuilder func view(for route: MyDayRoutes) -> some View {
        switch route {
        case .root:
            MyDayHomeScreen(
                dayManager: dayManager,
                addButtonAction: { [weak self] in
                    self?.navigate(to: .add)
                },
                addSpecificExercise: { [weak self] exercise in
                    self?.navigate(to: .reps(exercise))
                },
                recordClip: { [weak self] in
                    self?.coverFullScreen(with: .recordClip)
                }
            )
        case .add:
            MyDayExerciseListView(
                exerciseManager: exerciseManager,
                selectedExercise: { [weak self] exercise in
                    self?.navigate(to: .reps(exercise))
                }
            )
        case .reps(let exercise):
            MyDayKitRepsView(
                dayManager: dayManager,
                exercise: exercise,
                add: { [weak self] in
                    self?.navigate(to: .units(exercise))
                }
            )
        case .units(let exercise):
            MyDayUnitsHomeView(
                dayManager: dayManager,
                newExercise: exercise,
                optionSelected: { [weak self] option in
                    self?.optionSelected(option, exercise: exercise)
                },
                addedAction: { [weak self] in
                    self?.popToRoot()
                }
            )
        case .weight(let exercise):
            MyDayWeightSelectorView(
                newExercise: exercise,
                continueAction: { [weak self] in
                    self?.popBack()
            })
        case .distance(let exercise):
            MyDayDistanceSelectorView(
                newExercise: exercise,
                continueAction: { [weak self] in
                    self?.popBack()
                }
            )
        case .time(let exercise):
            MyDayTimeSelectorView(
                newExercise: exercise,
                continueAction: { [weak self] in
                    self?.popBack()
                }
            )
        case .tempo(let exercise):
            MyDayTempoSelectorView(
                newExercise: exercise,
                continueAction: { [weak self] in
                    self?.popBack()
                }
            )
        }
    }
    
    @ViewBuilder func sheet(for route: MyDaySheets) -> some View {
        switch route {
        case .add:
            MyDayExerciseListView(exerciseManager: exerciseManager)
        }
    }
    @ViewBuilder func fullScreenCover(for cover: MyDayFullScreenCover) -> some View {
        switch cover {
        case .recordClip:
            RecordClipScreen(
                dismiss: { [weak self] in
                    self?.fullScreenCover = nil
                }
            )
        }
    }
    
    func optionSelected(_ option: ExerciseOptions, exercise: MyDayNewExerciseManager) {
        switch option {
        case .weight:
            navigate(to: .weight(exercise))
        case .distance:
            navigate(to: .distance(exercise))
        case .time:
            navigate(to: .time(exercise))
        case .tempo:
            navigate(to: .tempo(exercise))
        case .note:
            navigate(to: .weight(exercise))
        }
    }
    
    func navigate(to route: MyDayRoutes) {
        path.append(route)
    }
    
    func presentSheet(_ sheet: MyDaySheets) {
        presentedSheet = sheet
    }
    
    func coverFullScreen(with cover: MyDayFullScreenCover) {
        fullScreenCover = cover
    }
    
    func popBack() {
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}
