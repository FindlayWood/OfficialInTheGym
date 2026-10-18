//
//  WelcomeView.swift
//  LoginKit
//
//  Created by Findlay-Personal on 05/04/2023.
//

import SwiftUI

/// The first screen anyone sees. It used to be a logo, one sentence and two buttons, which told
/// someone who had never heard of the app nothing about what it does. It now says it in three
/// cards (`WelcomeFeature`), each with a miniature of the screen it describes and a way to try it.
///
/// **Sign Up and Log In stay pinned at the bottom, unchanged**, so a returning user is not slowed
/// down by the pitch; on a small phone the cards scroll and the buttons do not.
///
/// **The showcase.** After the intro, the cards take turns: each rebuilds its miniature from empty —
/// the pills log from none to six, the chart grows from nothing, the ring fills from 0% — one card
/// at a time with a still pause between, so the loop tells the app's story (log → it adds up →
/// you're ready) and never moves two things at once. The playing card lifts slightly with a light
/// running round its edge, and the line under the tagline names it. The first version animated once and then stopped, and the screen went dead; three cards
/// moving together would be noise. One beat every few seconds is the line between the two.
///
/// It **holds still** while the user is scrolling or pressing a card, and stops when the screen is
/// not showing or the app is not active (`.task` is cancelled on disappear). With Reduce Motion on
/// there is no showcase: everything is drawn finished, and the line is the full sentence.
struct WelcomeView: View {

    @ObservedObject var viewModel: WelcomeViewModel

    var image: UIImage

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var isRevealed = false

    // MARK: - Showcase

    /// The card playing now, `nil` during the intro.
    @State private var activeFeature: WelcomeFeature?
    /// How many scenes each card has played — each new value is one beat of its miniature.
    @State private var scenes: [WelcomeFeature: Int] = [:]
    /// Mirrored into state rather than read from the environment inside the loop: the loop runs on
    /// a copy of the view, and an environment value read there would never change.
    @State private var isAppActive = true
    @State private var isScrolling = false
    @State private var isPressing = false
    @State private var tapCount = 0

    private var isShowcasePaused: Bool { isScrolling || isPressing || !isAppActive }

    /// The full sentence the rotating line stands in for — what VoiceOver reads, and what is shown
    /// with Reduce Motion on.
    private let pitch = "Plan your training, log every set, and see it add up."

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 24)
                        .padding(.bottom, 24)

                    VStack(spacing: 10) {
                        ForEach(viewModel.features) { feature in
                            WelcomeFeatureCard(
                                feature: feature,
                                isRevealed: isRevealed,
                                scene: scenes[feature, default: 0],
                                isActive: activeFeature == feature,
                                onPressChange: { isPressing = $0 }
                            ) {
                                tapCount += 1
                                viewModel.open(feature)
                            }
                        }
                    }
                }
                // Inside the scroll view, not around it: a scroll view clips to its bounds, and the
                // active card's lift and the light round its edge reach past the card. With the
                // padding outside, both were cut off at the left and right.
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
                .padding(.bottom, 12)
            }
            .onScrollPhaseChange { _, phase in
                isScrolling = phase.isScrolling
            }

            // Two full-width buttons rather than a primary and a word inside a sentence. Logging in
            // is half of what this screen is for, and "LOGIN" tucked into "Already have an
            // acccount?" — typo included — made it the harder of the two to hit.
            VStack(spacing: 10) {
                LoginPrimaryButton(title: "Sign Up") {
                    viewModel.signupAction()
                }
                LoginSecondaryButton(title: "Log In") {
                    viewModel.loginAction()
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            // A press that ended by navigating away may never report its release, which would
            // leave the showcase paused for good on the way back.
            isPressing = false
            isScrolling = false
            reveal()
        }
        .task { await runShowcase() }
        .onChange(of: scenePhase) { _, phase in
            isAppActive = phase == .active
        }
        .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 88, maxHeight: 88)

            Text(viewModel.title)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(Color.darkColor)
                .padding(.top, 12)

            // The tone, then what the app does. "Powering elite athletes" was considered and set
            // aside: it claims who uses the app, and reads as "not for me" to most people
            // downloading it — revisit once there are athletes to name.
            Text("Train like an athlete.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)
                .padding(.top, 4)

            headline
                .padding(.top, 6)
                .padding(.horizontal, 12)
        }
    }

    /// Follows the playing card. One fixed line high, so the cards below never move as it changes;
    /// before the showcase starts it reads as the two halves of the pitch.
    @ViewBuilder
    private var headline: some View {
        if reduceMotion {
            Text(pitch)
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            ZStack {
                Text(activeFeature?.headline ?? "Log every set. See it add up.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                    .id(activeFeature)
                    .transition(.push(from: .bottom))
            }
            .frame(height: 20)
            .clipped()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(pitch)
        }
    }

    // MARK: - Showcase

    /// Waits for the intro to finish, then plays each card's scene in turn for as long as the
    /// screen is showing. A scene is a highlight, a beat of the miniature, and a still pause before
    /// the next card — long enough that the screen reads as calm rather than busy.
    private func runShowcase() async {
        guard !reduceMotion, !viewModel.features.isEmpty else { return }
        // The intro's longest piece (the readiness ring) settles at about 1.4s after the reveal.
        try? await Task.sleep(for: .seconds(2.2))

        var index = 0
        while !Task.isCancelled {
            while isShowcasePaused {
                try? await Task.sleep(for: .milliseconds(250))
                if Task.isCancelled { return }
            }

            let feature = viewModel.features[index % viewModel.features.count]
            withAnimation(.easeInOut(duration: 0.35)) {
                activeFeature = feature
            }
            // A moment for the highlight to land before the miniature moves under it.
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                scenes[feature, default: 0] += 1
            }

            try? await Task.sleep(for: .seconds(3.2))
            index += 1
        }
    }

    // MARK: - Reveal

    private func reveal() {
        guard !isRevealed else { return }
        if reduceMotion {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { isRevealed = true }
        } else {
            // A beat after the screen lands, so the movement is seen rather than missed in the push.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isRevealed = true
            }
        }
    }
}

#Preview {
    WelcomeView(
        viewModel: WelcomeViewModel(title: "INTHEGYM", features: WelcomeFeature.allCases),
        image: UIImage(systemName: "figure.strengthtraining.traditional")!
    )
}
