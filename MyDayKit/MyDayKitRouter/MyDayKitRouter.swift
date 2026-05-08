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
    case note(MyDayNewExerciseManager)
    
    case workoutCreationHome
    
    case fitnessPicker
    case fitnessDetail(MyDayNewFitnessManager)
    
    case sportPicker
    case sportDetail(MyDayNewSportManager)
}

enum MyDaySheets: Identifiable {
    var id: String {
        switch self {
        case .add:
            return "add"
        case .option:
            return "option"
        }
    }
    
    case add
    case option
}

enum MyDayFullScreenCover: Identifiable {
    var id: String {
        switch self {
        case .recordClip:
            return "recordClip"
        case .viewClip:
            return "viewClip"
        }
    }
    case recordClip(String)
    case viewClip(MyDayClipModel, UIImage, CGRect)
}

public class MyDayKitRouter: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var presentedSheet: MyDaySheets?
    @Published var fullScreenCover: MyDayFullScreenCover?
    
    let exerciseManager: ExerciseManager
    let dayManager: MyDayManager
    let videoConverter: VideoConverter
    let uploadManager: UploadManager
    
    public init(exerciseManager: ExerciseManager, dayManager: MyDayManager, videoConverter: VideoConverter, uploadManager: UploadManager) {
        self.exerciseManager = exerciseManager
        self.dayManager = dayManager
        self.videoConverter = videoConverter
        self.uploadManager = uploadManager
    }
    
    @ViewBuilder func view(for route: MyDayRoutes) -> some View {
        switch route {
        case .root:
            MyDayHomeScreen(
                dayManager: dayManager,
                addButtonAction: { [weak self] in
                    self?.presentSheet(.option)
//                    self?.navigate(to: .add)
                },
                addSpecificExercise: { [weak self] exercise in
                    self?.navigate(to: .reps(exercise))
                },
                recordClip: { [weak self] exerciseID in
                    self?.coverFullScreen(with: .recordClip(exerciseID))
                },
                edit: { [weak self] exerciseManager in
                    self?.navigate(to: .reps(exerciseManager))
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
        case .note(let exercise):
            MyDayNoteSelectorView(
                newExercise: exercise,
                continueAction: { [weak self] in
                    self?.popBack()
                }
            )
        case .workoutCreationHome:
            MyDayWorkoutCreationHomeScreen(manager: WorkoutBuilderManager())
        case .fitnessPicker:
            FitnessActivityPickerView()
        case .fitnessDetail(let manager):
            FitnessSessionDetailView(manager: manager)
        case .sportPicker:
            SportPickerView()
        case .sportDetail(let manager):
            SportSessionDetailView(manager: manager)
        }
    }
    
    @ViewBuilder func sheet(for route: MyDaySheets) -> some View {
        switch route {
        case .add:
            MyDayExerciseListView(exerciseManager: exerciseManager)
        case .option:
            SelectOptionSheet(
                exerciseSelected: { [weak self] in
                    self?.presentedSheet = nil
                    self?.navigate(to: .add)
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    @ViewBuilder func fullScreenCover(for cover: MyDayFullScreenCover) -> some View {
        switch cover {
        case .recordClip(let exerciseID):
            RecordClipScreen(
                uploadManager: uploadManager,
                videoConverter: videoConverter,
                myDayManager: dayManager,
                exerciseID: exerciseID,
                dismiss: { [weak self] in
                    self?.fullScreenCover = nil
                },
                uploadComplete: { [weak self] in
                    self?.fullScreenCover = nil
                }
            )
        case let .viewClip(model, image, frame):
            Text("")
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
            navigate(to: .note(exercise))
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
