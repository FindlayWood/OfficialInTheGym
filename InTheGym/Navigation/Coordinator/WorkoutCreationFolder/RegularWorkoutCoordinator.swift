//
//  CreatingWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol CreationFlow: AnyObject {
    func addExercise(_ exercise: exercise)
    func exerciseSelected(_ exercise: exercise)
    func otherSelected(_ exercise: exercise)
    func repsSelected(_ exercise: exercise)
    func weightSelected(_ exercise: exercise)
    func completeExercise()
}

protocol LiveWorkoutDisplayFlow: AnyObject {
    func liveWorkoutCompleted()
    func addSet(_ exercise: exercise)
}

protocol CircuitFlow: AnyObject {
    func addExercise(_ circuit: exercise)
}

protocol AMRAPFlow: AnyObject {
    func addExercise(_ exercise: exercise)
}

protocol EMOMFlow: AnyObject {
    func addExercise(_ exercise: exercise)
}

protocol RegularAndCircuitFlow: AnyObject {
    func setsSelected(_ exercise: exercise)
}

protocol RegularAndLiveFlow: AnyObject {
    func circuitSelected()
    func amrapSelected()
    func emomSelected()
}

protocol EmomParentDelegate: AnyObject {
    func finishedCreatingEMOM(emomModel: EMOM)
}
protocol AmrapParentDelegate: AnyObject {
    func finishedCreatingAMRAP(amrapModel: AMRAP)
}
protocol CircuitParentDelegate: AnyObject {
    func finishedCreatingCircuit(circuitModel: circuit)
}
