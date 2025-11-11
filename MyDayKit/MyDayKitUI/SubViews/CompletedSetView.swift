//
//  CompletedSetView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct CompletedSetView: View {
    
    let model: ExerciseCompletions
    let animation: Namespace.ID
    
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
            RoundedRectangle(cornerRadius: 8)
                .matchedGeometryEffect(id: "\(model.id)background", in: animation)
                .foregroundStyle(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.5)
                        .stroke(Color.black, lineWidth: 1)
                        .matchedGeometryEffect(id: "\(model.id)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 2)
    }
}

#Preview {
    @Previewable @Namespace var animation
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
        ),
        animation: animation
    )
}
