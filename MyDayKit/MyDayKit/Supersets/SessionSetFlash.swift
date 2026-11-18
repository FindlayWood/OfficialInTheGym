//
//  SessionSetFlash.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// The set the session screen is pointing at after a log: which one, and a fresh `token` each
/// time, so pointing at the same set twice still flashes it twice.
struct SessionSetFlash: Equatable {
    let exerciseId: String
    let setId: String
    let token = UUID()
}

/// The ring a set pill flashes when it is the set to do next (`WorkoutSetOrder.next`).
///
/// It sits on **every** pill, and only the target draws: a keyframe animation runs when its
/// trigger changes, so a ring added at the moment of the flash would never animate. The pill the
/// flash moves off also sees its trigger change, which is why the value is masked by `isTarget`.
struct SessionSetFlashRing: View {

    let flash: SessionSetFlash?
    let setId: String

    private var isTarget: Bool { flash?.setId == setId }

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(Color.darkColor, lineWidth: 2.5)
            .keyframeAnimator(initialValue: 0.0, trigger: flash?.token) { ring, opacity in
                ring.opacity(isTarget ? opacity : 0)
            } keyframes: { _ in
                // Two pulses after the scroll has had a moment to land, then gone.
                LinearKeyframe(0, duration: 0.25)
                LinearKeyframe(1, duration: 0.18)
                LinearKeyframe(0.25, duration: 0.25)
                LinearKeyframe(1, duration: 0.2)
                LinearKeyframe(0, duration: 0.6)
            }
            .allowsHitTesting(false)
    }
}
