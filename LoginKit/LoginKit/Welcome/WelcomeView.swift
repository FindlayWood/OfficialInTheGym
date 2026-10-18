//
//  WelcomeView.swift
//  LoginKit
//
//  Created by Findlay-Personal on 05/04/2023.
//

import SwiftUI

struct WelcomeView: View {

    @ObservedObject var viewModel: WelcomeViewModel

    var image: UIImage

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 180, maxHeight: 180)

            Text(viewModel.title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.darkColor)
                .padding(.top, 16)

            Text("Plan your training, log every set, and see it add up.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.horizontal, 24)

            if viewModel.canTryWorkout {
                tryWorkoutButton
                    .padding(.top, 24)
            }

            Spacer()

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
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    /// A tinted capsule rather than a third full-width button: signing up and logging in are what
    /// this screen is for, and the example workout is a look before choosing — it sits with the
    /// pitch it illustrates, not with the actions.
    private var tryWorkoutButton: some View {
        Button {
            viewModel.tryWorkoutAction()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Try an example workout")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(Color.darkColor)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .background(Capsule().fill(Color.darkColor.opacity(0.12)))
        }
    }
}

#Preview {
    WelcomeView(
        viewModel: WelcomeViewModel(title: "INTHEGYM", canTryWorkout: true),
        image: UIImage(systemName: "figure.strengthtraining.traditional")!
    )
}
