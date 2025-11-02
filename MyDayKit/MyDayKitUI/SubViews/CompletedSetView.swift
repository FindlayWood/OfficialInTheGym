//
//  CompletedSetView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct CompletedSetView: View {
    
    let model: ExerciseCompletions
    
    var body: some View {
        VStack {
            Text("\(model.reps)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.black)
            if let weight = model.weight, let unit = model.weightUnit {
                Text("\(weight) \(unit.rawValue)")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black)
            }
        }
        .padding()
        .frame(width: 100, height: 100)
        .background {
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        }
    }
}

#Preview {
    CompletedSetView(
        model: .init(
            id: "1",
            exercise: .pressUps,
            reps: 10,
            weight: 20,
            weightUnit: .kg,
            dateCompleted: .now,
            distance: nil,
            distanceUnits: nil,
            time: nil,
            tempo: nil,
            note: nil
        )
    )
}
