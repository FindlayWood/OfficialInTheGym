//
//  PlaceholderSetView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/11/2025.
//

import SwiftUI

struct PlaceholderSetView: View {
    
    let model: ExerciseCompletions
    
    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text("\(model.reps)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.black)
                Text("\(model.reps > 1 ? "reps" : "rep")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.5))
            }
            if let weight = model.weight, let unit = model.weightUnit {
                if unit != .max, unit != .bw {
                    Text("\(weight) \(unit.rawValue)")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.black)
                } else {
                    Text("\(unit.rawValue)")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.black)
                }
            }
            if let time = model.time {
                Text("\(time)s")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.black)
            }
        }
        .padding()
        .frame(width: 100, height: 100)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.thirdColour)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.5)
                        .stroke(Color.black, lineWidth: 1)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 2)
    }
}

#Preview {
    PlaceholderSetView(
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
            note: nil,
            eachSide: nil
        )
    )
}
