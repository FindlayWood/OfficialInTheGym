//
//  WorkoutFiguresView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 18/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct WorkoutFiguresView: View {
    var model: WorkoutModel
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Text(model.exercises?.count ?? 0, format: .number)
                    .font(.body.bold())
                    .foregroundColor(.primary)
                Text("Exercises")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            if model.completed == true {
                if let time = model.timeToComplete {
                    VStack {
                        Text(time.convertToWorkoutTime())
                            .font(.body.bold())
                            .foregroundColor(.primary)
                        Text("Duration")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                }
                if let rpe = model.score {
                    VStack {
                        Text(rpe, format: .number)
                            .font(.body.bold())
                            .foregroundColor(.primary)
                        Text("RPE")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                    }
                }
            }
        }
    }
}
