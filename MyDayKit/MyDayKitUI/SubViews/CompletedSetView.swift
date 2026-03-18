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
        VStack(spacing: 2) {
            
            // ── Reps ───────────────────────────────────────────────────
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(model.reps)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text(model.reps > 1 ? "reps" : "rep")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            
            // ── Each side indicator ────────────────────────────────────
            if model.eachSide ?? false {
                Text("each side")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .clipShape(Capsule())
            }
            
            // ── Weight ─────────────────────────────────────────────────
            if let weight = model.weight, let unit = model.weightUnit {
                if unit != .max, unit != .bw {
                    Text("\(weight.formatted(.number.precision(.fractionLength(0...2)))) \(unit.rawValue)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    Text(unit.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.blue)
                }
            }
            
            // ── Time ───────────────────────────────────────────────────
            if let time = model.time {
                HStack(spacing: 2) {
                    Image(systemName: "clock")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.secondary)
                    Text("\(time)s")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .frame(width: 100, height: 100)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .matchedGeometryEffect(id: "\(model.id)background", in: animation)
                .foregroundStyle(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.5)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        .matchedGeometryEffect(id: "\(model.id)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            note: nil,
            eachSide: nil
        ),
        animation: animation
    )
}
