//
//  ExerciseStatsListRow.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct ExerciseStatsListRow: View {
    var model: ExerciseStatsModel
    
    var body: some View {
        VStack {
            Text(model.exerciseName)
                .font(.headline)
                .foregroundColor(Color(.darkColour))
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
