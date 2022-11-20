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
                    .font(.title3)
                    .foregroundColor(.primary)
                Image("dumbbell_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
            }
            if model.completed == true {
                if let time = model.timeToComplete {
                    VStack {
                        Text(time.convertToWorkoutTime())
                            .font(.body)
                            .foregroundColor(.gray)
                        Image("clock_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                    }
                }
                if let rpe = model.score {
                    VStack {
                        Text(rpe, format: .number)
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                        Text("RPE")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                        
                    }
                }
            }
        }
    }
}
