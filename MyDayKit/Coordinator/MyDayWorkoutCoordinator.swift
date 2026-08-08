//
//  MyDayWorkoutCoordinator.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/05/2026.
//

import UIKit
import SwiftUI

class MyDayWorkoutCoordinator {
    
    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let exerciseManager: ExerciseManager
    let dayManager: MyDayManager
    let videoConverter: VideoConverter
    let uploadManager: UploadManager
    let clipLoader: ClipLoader
    let clipViewRecorder: ViewClipRecorder
    /// Held here so every route in the exercise-add flow can read/write it.
    let workoutManager: WorkoutBuilderManager
    let libraryManager: WorkoutLibraryManager
    
    // MARK: - Callbacks

    var onWorkoutAddedToDay: (() -> Void)?

    // MARK: - State

    /// The root VC of *this* coordinator. Set once in start() so we can pop
    /// back to it without blowing past the parent coordinator's stack.
    private weak var rootViewController: UIViewController?
    private weak var creationRootViewController: UIViewController?

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        exerciseManager: ExerciseManager,
        dayManager: MyDayManager,
        videoConverter: VideoConverter,
        uploadManager: UploadManager,
        clipLoader: ClipLoader,
        clipViewRecorder: ViewClipRecorder,
        workoutManager: WorkoutBuilderManager,
        libraryManager: WorkoutLibraryManager
    ) {
        self.navigationController = navigationController
        self.exerciseManager = exerciseManager
        self.dayManager = dayManager
        self.videoConverter = videoConverter
        self.uploadManager = uploadManager
        self.clipLoader = clipLoader
        self.clipViewRecorder = clipViewRecorder
        self.workoutManager = workoutManager
        self.libraryManager = libraryManager
    }

    // MARK: - Root

    public func start() -> UIViewController {
        let rootVC = viewController(for: .library)
        rootViewController = rootVC
        return rootVC
    }
}

extension MyDayWorkoutCoordinator {
    
    func viewController(for route: MyDayWorkoutRoutes) -> UIViewController {
        switch route {
        case .library:
            let vc = selectorVC(
                MyDayWorkoutLibraryScreen(
                    manager: libraryManager,
                    onWorkoutSelected: { [weak self] model in
                        self?.navigate(to: .templateDetail(model))
                    },
                    onCreateNewTapped: { [weak self] in
                        self?.navigate(to: .creation)
                    }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        case .templateDetail(let template):
            // Hosted with the nav bar hidden so the set detail overlay can dim
            // over the whole screen; the screen draws `MyDayWorkoutNavBar`
            // itself and pops through `onBack`.
            let vc = NavBarHidingHostingController(
                rootView: MyDayWorkoutTemplateDetailScreen(
                    template: template,
                    onAddToTodayTapped: dayManager.addWorkoutToDay,
                    onReadyToDismiss: { [weak self] in
                        self?.onWorkoutAddedToDay?()
                    },
                    onBack: { [weak self] in
                        self?.popBack()
                    }
                )
            )
            return vc
        case .creation:
            workoutManager.onUploadSuccess = libraryManager.addTemplate
            let vc = selectorVC(
                MyDayWorkoutCreationHomeScreen(
                    manager: workoutManager,
                    onOptionsTapped: { [weak self] in
                        self?.presentSheet(.workoutSettings)
                    },
                    addExerciseTapped: { [weak self] in
                        self?.navigate(to: .exercise)
                    },
                    uploadComplete: { [weak self] in
                        self?.popToCoordinatorRoot()
                    }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            creationRootViewController = vc
            return vc
        case .exercise:
            let vc = UIHostingController(
                rootView: MyDayExerciseListView(
                    exerciseManager: exerciseManager,
                    selectedWorkoutExercise: { [weak self] exercise in
                        let manager = WorkoutExerciseBuilderManager(exercise: exercise)
                        self?.navigate(to: .sets(manager))
                    }
                )
            )
            return vc
        case .sets(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutSetsScreen(
                    manager: manager,
                    add: { [weak self] in
                        self?.navigate(to: .reps(manager))
                    }
                )
            )
            return vc
            
        case .reps(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutBuilderRepsScreen(
                    exercise: manager,
                    add: { [weak self] in
                        self?.navigate(to: .units(manager))
                    }
                )
            )
            return vc
        case .units(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutBuilderUnitsScreen(
                    exercise: manager,
                    optionSelected: { [weak self] option in
                        switch option {
                        case .weight:
                            self?.navigate(to: .weight(manager))
                        case .distance:
                            self?.navigate(to: .distance(manager))
                        case .time:
                            self?.navigate(to: .time(manager))
                        case .tempo:
                            self?.navigate(to: .tempo(manager))
                        case .note:
                            self?.navigate(to: .note(manager))
                        }
                    },
                    continueAction: { [weak self] in
                        guard let self else { return }
                        // Append the finished exercise to the workout, then
                        // pop all the way back to the creation home screen.
                        DispatchQueue.main.async {
                            self.workoutManager.addExercise(manager)
                            self.popToCreationCoordinatorRoot()
                        }
                    }
                )
            )
            return vc
        case .weight(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutBuilderWeightScreen(
                    exercise: manager,
                    continueAction: { [weak self] in
                        self?.popBack()
                    }
                )
            )
            return vc
        case .distance(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutBuilderDistanceScreen(
                    exercise: manager,
                    continueAction: { [weak self] in
                        self?.popBack()
                    }
                )
            )
            return vc
        case .time(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutBuilderTimeScreen(
                    exercise: manager,
                    continueAction: { [weak self] in
                        self?.popBack()
                    }
                )
            )
            return vc
        case .tempo(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutBuilderTempoScreen(
                    exercise: manager,
                    continueAction: { [weak self] in
                        self?.popBack()
                    }
                )
            )
            return vc
        case .note(let manager):
            let vc = UIHostingController(
                rootView: MyDayWorkoutBuilderNoteScreen(
                    exercise: manager,
                    continueAction: { [weak self] in
                        self?.popBack()
                    }
                )
            )
            return vc
        }
    }
    
    private func selectorVC<Content: View>(_ view: Content) -> UIViewController {
        UIHostingController(rootView: view)
    }
}

extension MyDayWorkoutCoordinator {

    func navigate(to route: MyDayWorkoutRoutes) {
        let vc = viewController(for: route)
        navigationController.pushViewController(vc, animated: true)
    }

    func popBack() {
        navigationController.popViewController(animated: true)
    }

    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    /// Pops back to this coordinator's own root VC, not the nav stack's root.
    func popToCoordinatorRoot() {
        guard let rootViewController else {
            // Fallback: pop one level rather than blowing past the parent.
            navigationController.popViewController(animated: true)
            return
        }
        navigationController.popToViewController(rootViewController, animated: true)
    }
    
    /// Pops back to this coordinator's own root VC, not the nav stack's root.
    func popToCreationCoordinatorRoot() {
        guard let creationRootViewController else {
            // Fallback: pop one level rather than blowing past the parent.
            navigationController.popViewController(animated: true)
            return
        }
        navigationController.popToViewController(creationRootViewController, animated: true)
    }
}

extension MyDayWorkoutCoordinator {

    func presentSheet(_ sheet: MyDayWorkoutSheets) {
        let vc: UIViewController

        switch sheet {
        case .workoutSettings:
            let hosting = UIHostingController(
                rootView: WorkoutSettingsSheet()
            )
            vc = hosting
        }

        navigationController.present(vc, animated: true)
    }
}
