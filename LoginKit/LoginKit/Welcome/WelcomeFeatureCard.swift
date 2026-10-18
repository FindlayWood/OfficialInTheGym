//
//  WelcomeFeatureCard.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// One welcome-screen feature: a miniature of the screen it describes beside the line about it.
/// The whole card is the button.
///
/// **The picture is the app's own UI, drawn small** — set pills, the weekly bars, the fatigue
/// reading — not an icon or a photo. When "Try a workout" opens and the same pills appear full
/// size, the welcome screen has kept its promise; a photo of someone lifting would only have said
/// "gym app". The miniatures are hand-drawn here, since LoginKit imports none of the frameworks
/// that own the real components, and they are illustrations with fixed numbers, not data.
///
/// `scene` counts the turns this card has had in `WelcomeView`'s showcase; each new value rebuilds
/// its miniature from empty (`WelcomeRebuilding`). `isActive` is the card whose turn it is, lifted
/// slightly with a light running round its edge (`WelcomeCardSweep`) so the eye follows it.
struct WelcomeFeatureCard: View {

    let feature: WelcomeFeature
    let isRevealed: Bool
    var scene: Int = 0
    var isActive: Bool = false
    var onPressChange: ((Bool) -> Void)?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                illustration
                    .frame(width: 88, height: 64)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(feature.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        if feature.isPro {
                            Text("PRO")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.darkColor))
                        }
                    }
                    Text(feature.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 3) {
                        Text(feature.actionTitle)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .padding(.top, 3)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay { WelcomeCardSweep(isActive: isActive) }
            .scaleEffect(isActive ? 1.01 : 1)
            .animation(.easeInOut(duration: 0.35), value: isActive)
            .contentShape(Rectangle())
        }
        .buttonStyle(WelcomeCardButtonStyle(onPressChange: onPressChange))
    }

    private var illustration: some View {
        WelcomeRebuilding(isRevealed: isRevealed, scene: scene) { isBuilt in
            switch feature {
            case .training: WelcomeSetPillsIllustration(isBuilt: isBuilt)
            case .stats: WelcomeWeeklyBarsIllustration(isBuilt: isBuilt)
            case .performance: WelcomeReadinessIllustration(isBuilt: isBuilt)
            }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        ForEach(WelcomeFeature.allCases) { feature in
            WelcomeFeatureCard(feature: feature, isRevealed: true, isActive: feature == .stats) {}
        }
    }
    .padding()
}
