//
//  CompletedSetView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

/// A logged set on the MyDay home screen, drawn as a **completed**
/// `SessionSetPill`: same 72×88 frame, same radius, same dark fill and white
/// text. Every completion here has already been performed, so it is always in
/// the logged state — there is no empty variant.
///
/// Values come from `SessionSetPillValue.values(for:)`, which caps them at two
/// in priority order reps → weight → time → distance. **Do not lay this out to
/// fit whatever the set happens to hold** — four measures overflow the frame and
/// clip the text top and bottom, which is the whole reason the cap exists.
///
/// Keep in step with `SessionSetPill`, and with `PlaceholderSetView`, which
/// holds this pill's slot during the hero flight into `SetDetailView`.
struct CompletedSetView: View {

    let index: Int
    let model: ExerciseCompletions
    let animation: Namespace.ID

    private var values: [SessionSetPillValue] {
        SessionSetPillValue.values(for: model)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Set \(index + 1)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(0.5)

            ForEach(Array(values.enumerated()), id: \.element.id) { position, value in
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value.value)
                        .font(.system(size: position == 0 ? 16 : 12, weight: position == 0 ? .bold : .semibold))
                    if let unit = value.unit {
                        Text(unit)
                            .font(.system(size: 10))
                    }
                }
                .foregroundStyle(position == 0 ? Color.white : Color.white.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 4)

            // The session pill's logged state ends in this checkmark, and every
            // completion here is logged — so drawing it makes the two pills
            // identical rather than merely similar. Indicator only: the whole
            // pill is the tap target, as it is on the session screen.
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.white)
        }
        .frame(width: 72, height: 88)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .matchedGeometryEffect(id: "\(model.id)background", in: animation)
                .foregroundStyle(Color.darkColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .inset(by: 0.5)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        .matchedGeometryEffect(id: "\(model.id)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var animation

    let completion: (Int, Double?, WeightUnit?, Int?, Bool?) -> ExerciseCompletions = {
        reps, weight, unit, time, eachSide in
        ExerciseCompletions(
            id: UUID().uuidString,
            exercise: .pressUps,
            reps: reps,
            weight: weight,
            weightUnit: unit,
            dateCompleted: .now,
            distance: nil,
            distanceUnits: nil,
            time: time,
            tempo: nil,
            note: nil,
            eachSide: eachSide
        )
    }

    HStack(spacing: 8) {
        CompletedSetView(index: 0, model: completion(10, 20, .kg, nil, nil), animation: animation)
        CompletedSetView(index: 1, model: completion(25, nil, .bw, nil, nil), animation: animation)
        CompletedSetView(index: 2, model: completion(12, nil, nil, nil, true), animation: animation)
        CompletedSetView(index: 3, model: completion(8, 100, .kg, 90, nil), animation: animation)
    }
    .padding(20)
    .background(Color.white)
}
