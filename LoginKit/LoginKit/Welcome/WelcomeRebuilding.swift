//
//  WelcomeRebuilding.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// Drives a welcome miniature's one state, built or empty, and rebuilds it from empty on every new
/// `scene`: a quick clear, a beat, then the build again.
///
/// **Every turn plays the whole build** — no pills to six, an empty chart to its twelve weeks, the
/// ring from 0 to its reading. The first showcase played one increment per turn instead (one more
/// pill, the chart rolled a week), which only made sense if you had watched the turn before; a
/// build from empty is the whole story each time. Owning it here keeps the three miniatures pure
/// drawings of `isBuilt`, each choosing its own build animation.
///
/// With Reduce Motion the miniature is built once, without animation, and never cleared.
struct WelcomeRebuilding<Content: View>: View {

    let isRevealed: Bool
    let scene: Int
    @ViewBuilder let content: (_ isBuilt: Bool) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isBuilt = false

    /// How long the cleared miniature sits empty before building — long enough to read as a fresh
    /// start rather than a glitch.
    private let emptyBeat: Duration = .milliseconds(350)

    var body: some View {
        content(isBuilt)
            .onAppear { if isRevealed { build() } }
            .onChange(of: isRevealed) { _, isRevealed in
                if isRevealed { build() }
            }
            .task(id: scene) {
                guard scene > 0, !reduceMotion else { return }
                isBuilt = false
                try? await Task.sleep(for: emptyBeat)
                guard !Task.isCancelled else { return }
                isBuilt = true
            }
    }

    private func build() {
        if reduceMotion {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { isBuilt = true }
        } else {
            isBuilt = true
        }
    }
}
