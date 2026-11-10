//
//  InjuryImpactPicker.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// How much the injury is changing training: three pills, one selected. See `InjuryImpact` for
/// why there are three and not two.
struct InjuryImpactPicker: View {

    let selected: InjuryImpact?
    let onSelect: (InjuryImpact) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(InjuryImpact.allCases, id: \.self) { impact in
                let isSelected = impact == selected
                Button {
                    onSelect(impact)
                } label: {
                    Text(impact.title)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isSelected ? Color.darkColor : Color(.tertiarySystemGroupedBackground))
                        )
                        .foregroundStyle(isSelected ? Color.white : Color.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(impact.summary)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .animation(.easeInOut(duration: 0.15), value: selected)
    }
}
