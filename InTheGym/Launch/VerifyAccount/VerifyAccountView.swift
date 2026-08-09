//
//  VerifyAccountView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct VerifyAccountView: View {

    @ObservedObject var viewModel: VerifyAccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "envelope.badge")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(Color(.darkColour))

            // "Account Created" — which is what this said — is the one thing that has not happened
            // yet. The account is not usable until the email is verified and the profile is filled
            // in, and saying otherwise makes the two screens after this one look like a mistake.
            Text("Check your email")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primary)
                .padding(.top, 24)

            Text("We've sent you a link to verify your address.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)

            // The address gets a card of its own: a typo here is the single most likely reason the
            // email never arrives, and it is the one thing on this screen the user can check.
            HStack(spacing: 10) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.darkColour))
                Text(viewModel.email ?? "your email address")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.top, 20)

            Text("Tap the link in the email, then come back here. If it hasn't arrived, check your junk folder.")
                .font(.system(size: 13))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 16)

            // The screen polls every two seconds and moves on by itself, so this says the waiting is
            // being done for them — otherwise a verified user is left staring at an unchanged screen
            // wondering what to press.
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Waiting for you to verify...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 12) {
                if viewModel.resendState == .failed {
                    VerifyEmailErrorBanner(
                        message: "We couldn't send that email. Check your connection and try again."
                    )
                }

                resendButton

                Button {
                    viewModel.logoutAction()
                } label: {
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Resend

    private var resendButton: some View {
        Button {
            viewModel.resendVerificationEmailAction()
        } label: {
            Group {
                switch viewModel.resendState {
                case .sending:
                    ProgressView()
                        .controlSize(.small)
                        .tint(Color.secondary)
                case .sent(let secondsRemaining):
                    Label("Email sent — resend in \(secondsRemaining)s", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                case .idle, .failed:
                    Text("Resend Verification Email")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isResendEnabled ? Color(.darkColour) : Color(UIColor.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(!isResendEnabled)
        .animation(.easeInOut(duration: 0.15), value: viewModel.resendState)
    }

    private var isResendEnabled: Bool {
        viewModel.resendState == .idle || viewModel.resendState == .failed
    }
}

#Preview {
    VerifyAccountView(viewModel: VerifyAccountViewModel())
}
