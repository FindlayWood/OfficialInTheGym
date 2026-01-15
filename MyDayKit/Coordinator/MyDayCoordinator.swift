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

    // MARK: - Init

    public init(
        navigationController: UINavigationController,
        exerciseManager: ExerciseManager,
        dayManager: MyDayManager
    ) {
        self.navigationController = navigationController
        self.exerciseManager = exerciseManager
        self.dayManager = dayManager
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
                recordClip: { [weak self] in
                    self?.presentFullScreen(.recordClip)
                },
                edit: { [weak self] exerciseManager in
                    self?.navigate(to: .reps(exerciseManager))
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
                    }
                )
            )

            if let sheet = hosting.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }

            vc = hosting
        }

        navigationController.present(vc, animated: true)
    }
}

extension MyDayCoordinator {

    func presentFullScreen(_ cover: MyDayFullScreenCover) {
        let vc: UIViewController

        switch cover {
        case .recordClip:
            vc = UIHostingController(
                rootView: RecordClipScreen(
                    dismiss: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                    }
                )
            )
            vc.modalPresentationStyle = .fullScreen
        }

        navigationController.present(vc, animated: true)
    }
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

