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
/// The miniatures animate **once**, as the screen appears, and then stop — a loop on a screen
/// people read is noise. With Reduce Motion on they are drawn already finished.
struct WelcomeView: View {

    @ObservedObject var viewModel: WelcomeViewModel

    var image: UIImage

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRevealed = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 24)
                        .padding(.bottom, 24)

                    VStack(spacing: 10) {
                        ForEach(viewModel.features) { feature in
                            WelcomeFeatureCard(feature: feature, isRevealed: isRevealed) {
                                viewModel.open(feature)
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
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
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear(perform: reveal)
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

            Text("Plan your training, log every set, and see it add up.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)
                .padding(.horizontal, 12)
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
