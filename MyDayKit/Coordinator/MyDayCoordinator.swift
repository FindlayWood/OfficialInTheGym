//
//  MyDayCoordinator.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/01/2026.
//

import UIKit
import SwiftUI

public final class MyDayCoordinator {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies

    let exerciseManager: ExerciseManager
    let dayManager: MyDayManager
    let videoConverter: VideoConverter
    let uploadManager: UploadManager
    let clipLoader: ClipLoader
    let clipViewRecorder: ViewClipRecorder
    let workoutManager: WorkoutBuilderManager
    let workoutLibraryManager: WorkoutLibraryManager
    
    // MARK: - Properties
    private var workoutCoordinator: MyDayWorkoutCoordinator?

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
        workoutLibraryManager: WorkoutLibraryManager
    ) {
        self.navigationController = navigationController
        self.exerciseManager = exerciseManager
        self.dayManager = dayManager
        self.videoConverter = videoConverter
        self.uploadManager = uploadManager
        self.clipLoader = clipLoader
        self.clipViewRecorder = clipViewRecorder
        self.workoutManager = workoutManager
        self.workoutLibraryManager = workoutLibraryManager
    }

    // MARK: - Root

    public func start() {
        let rootVC = viewController(for: .root)
        navigationController.setViewControllers([rootVC], animated: false)
    }
}

extension MyDayCoordinator {

    func viewController(for route: MyDayRoutes) -> UIViewController {

        switch route {

        case .root:
            let display = MyDayHomeScreen(
                dayManager: dayManager,
                addButtonAction: { [weak self] in
                    self?.presentSheet(.option)
                },
                addSpecificExercise: { [weak self] exercise in
                    self?.navigate(to: .reps(exercise))
                },
                recordClip: { [weak self] exerciseID in
                    self?.presentFullScreen(.recordClip(exerciseID))
                },
                edit: { [weak self] exerciseManager in
                    self?.navigate(to: .reps(exerciseManager))
                },
                clipSelected: { [weak self] model, thumbnail, frame in
                    self?.presentFullScreen(.viewClip(model, thumbnail, frame))
                }
            )
            let vc = MyDayBoundaryViewController()
            vc.display = display
            vc.coordinator = self
            return vc

        case .add:
            let vc = UIHostingController(
                rootView: MyDayExerciseListView(
                    exerciseManager: exerciseManager,
                    selectedExercise: { [weak self] exercise in
                        self?.navigate(to: .reps(exercise))
                    }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .reps(let exercise):
            let vc = UIHostingController(
                rootView: MyDayKitRepsView(
                    dayManager: dayManager,
                    exercise: exercise,
                    add: { [weak self] in
                        self?.navigate(to: .units(exercise))
                    }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc

        case .units(let exercise):
            return UIHostingController(
                rootView: MyDayUnitsHomeView(
                    dayManager: dayManager,
                    newExercise: exercise,
                    optionSelected: { [weak self] option in
                        self?.optionSelected(option, exercise: exercise)
                    },
                    addedAction: { [weak self] in
                        self?.popToRoot()
                    }
                )
            )

        case .weight(let exercise):
            return selectorVC(
                MyDayWeightSelectorView(
                    newExercise: exercise,
                    continueAction: { [weak self] in self?.popBack() }
                )
            )

        case .distance(let exercise):
            return selectorVC(
                MyDayDistanceSelectorView(
                    newExercise: exercise,
                    continueAction: { [weak self] in self?.popBack() }
                )
            )

        case .time(let exercise):
            return selectorVC(
                MyDayTimeSelectorView(
                    newExercise: exercise,
                    continueAction: { [weak self] in self?.popBack() }
                )
            )

        case .tempo(let exercise):
            return selectorVC(
                MyDayTempoSelectorView(
                    newExercise: exercise,
                    continueAction: { [weak self] in self?.popBack() }
                )
            )

        case .note(let exercise):
            return selectorVC(
                MyDayNoteSelectorView(
                    newExercise: exercise,
                    continueAction: { [weak self] in self?.popBack() }
                )
            )
        case .workoutCreationHome:
            let sub = MyDayWorkoutCoordinator(
                navigationController: navigationController,
                exerciseManager: exerciseManager,
                dayManager: dayManager,
                videoConverter: videoConverter,
                uploadManager: uploadManager,
                clipLoader: clipLoader,
                clipViewRecorder: clipViewRecorder,
                workoutManager: workoutManager,
                libraryManager: workoutLibraryManager
            )
            
            workoutCoordinator = sub
            return sub.start()
            
        case .fitnessPicker:
            let vc = selectorVC(
                FitnessActivityPickerView(
                    activitySelected: { [weak self] activity in
                        let ama = MyDayNewFitnessManager(activity: activity)
                        self?.navigate(to: .fitnessDetail(ama))
                    }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        case .fitnessDetail(let manager):
            return selectorVC(
                FitnessSessionDetailView(
                    manager: manager
                )
            )
        case .sportPicker:
            let vc = selectorVC(
                SportPickerView(
                    sportSelected: { [weak self] sport in
                        let manager = MyDayNewSportManager(sport: sport)
                        self?.navigate(to: .sportDetail(manager))
                    }
                )
            )
            vc.hidesBottomBarWhenPushed = true
            return vc
        case .sportDetail(let manager):
            let vc = selectorVC(
                SportSessionDetailView(
                    manager: manager
                )
            )
            return vc
        }
    }

    private func selectorVC<Content: View>(_ view: Content) -> UIViewController {
        UIHostingController(rootView: view)
    }
}

extension MyDayCoordinator {

    func navigate(to route: MyDayRoutes) {
        let vc = viewController(for: route)
        navigationController.pushViewController(vc, animated: true)
    }

    func popBack() {
        navigationController.popViewController(animated: true)
    }

    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}


extension MyDayCoordinator {

    func presentSheet(_ sheet: MyDaySheets) {
        let vc: UIViewController

        switch sheet {

        case .add:
            vc = UIHostingController(
                rootView: MyDayExerciseListView(
                    exerciseManager: exerciseManager
                )
            )

        case .option:
            let hosting = UIHostingController(
                rootView: SelectOptionSheet(
                    exerciseSelected: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                        self?.navigate(to: .add)
                    },
                    fitnessSelected: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                        self?.navigate(to: .fitnessPicker)
                    },
                    sportSelected: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                        self?.navigate(to: .sportPicker)
                    },
                    workoutSelected: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                        self?.navigate(to: .workoutCreationHome)
                    }
                )
            )

            if let sheet = hosting.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }

            vc = hosting
            
        case .workoutSettings:
            let hosting = UIHostingController(
                rootView: WorkoutSettingsSheet()
            )
            vc = hosting

        }

        navigationController.present(vc, animated: true)
    }
}

extension MyDayCoordinator {

    func presentFullScreen(_ cover: MyDayFullScreenCover) {
        let vc: UIViewController

        switch cover {
        case .recordClip(let exerciseID):
            vc = UIHostingController(
                rootView: RecordClipScreen(
                    uploadManager: uploadManager,
                    videoConverter: videoConverter,
                    myDayManager: dayManager,
                    exerciseID: exerciseID,
                    dismiss: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                    },
                    uploadComplete: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                    }
                )
            )
            vc.modalPresentationStyle = .fullScreen
        
        case let .viewClip(clip, thumbnail, thumbnailFrame):
            // View Model
            let viewModel = ViewClipViewModel(
                loader: clipLoader,
                clipModel: clip,
                clipViewRecorder: clipViewRecorder,
                dismissAction: { [weak self] in
                    self?.navigationController.dismiss(animated: true)
                    
                }
            )
            // Your existing ViewClipViewController
            let viewClipVC = ViewClipViewController()
            viewClipVC.clipModel = clip
            viewClipVC.thumbnail = thumbnail
            viewClipVC.viewModel = viewModel
            
            // Create custom transition
            let transitionDelegate = ClipFromSwiftUITransitionDelegate(
                thumbnail: thumbnail,
                thumbnailFrame: thumbnailFrame,
                destinationVC: viewClipVC
            )
            
            viewClipVC.modalPresentationStyle = .custom
            viewClipVC.transitioningDelegate = transitionDelegate
            
            // Keep the delegate alive
            objc_setAssociatedObject(
                viewClipVC,
                &AssociatedKeys.transitionDelegate,
                transitionDelegate,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            vc = viewClipVC
            vc.modalPresentationStyle = .fullScreen
        }
        
        navigationController.present(vc, animated: true)
    }
}

// To this:
private enum AssociatedKeys {
    static var transitionDelegate: UInt8 = 0
}

extension MyDayCoordinator {

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
}
