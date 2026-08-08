//
//  RepeatSetView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct RepeatSetView: View {
    
    let lastReps: Int?
    let lastWeight: Double?
    let lastWeightUnit: WeightUnit?
    var action: (() -> ())?
    
    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                
                if let reps = lastReps {
                    Text("\(reps) \(reps == 1 ? "rep" : "reps")")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
                
                if let weight = lastWeight, let unit = lastWeightUnit {
                    if unit != .max, unit != .bw {
                        Text("\(weight.formatted(.number.precision(.fractionLength(0...2)))) \(unit.rawValue)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.darkColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    } else {
                        Text(unit.rawValue)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.darkColor)
                    }
                }
            }
            .frame(width: 80, height: 80)
            .background(Color.darkColor.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.darkColor.opacity(0.25), lineWidth: 1)
            }
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    RepeatSetView(lastReps: 4, lastWeight: 20, lastWeightUnit: .kg)
}
