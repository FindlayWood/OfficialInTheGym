//
//  DeleteAccountScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// Delete Account, pushed from Settings. A plain list of what goes, the
/// password, and a red button behind a final confirmation. See
/// `DeleteAccountViewModel`.
///
/// The list is specific on purpose: "your data" is not an answer someone can
/// weigh. It names what they will actually miss, and says that a subscription
/// is cancelled in the App Store, not here, since deleting an account does not
/// stop Apple billing.
struct DeleteAccountScreen: View {

    @ObservedObject var viewModel: DeleteAccountViewModel
    @State private var confirming = false
    @FocusState private var passwordFocused: Bool

    private let losses = [
        ("person.crop.circle", "Your profile, photo, followers and the people you follow"),
        ("calendar", "Every logged day, workout and set, and your stats"),
        ("dumbbell", "Your workout library, including public workouts"),
        ("video", "Your clips, comments, ratings and likes"),
        ("figure.stand", "Your body measurements and weight log")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("This permanently deletes your account")
                        .font(.system(size: 20, weight: .bold))
                    Text("It can't be undone, and we can't recover anything afterwards.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.secondary)
                }

                ProfileSettingsSection(title: "What's deleted") {
                    ForEach(Array(losses.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: item.0)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.secondary)
                                .frame(width: 24)
                            Text(item.1)
                                .font(.system(size: 15))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        if index < losses.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }

                Text("If you subscribe to INTHEGYM pro, cancel it in the App Store as well. Deleting your account doesn't stop Apple billing.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)

                EditProfileFieldCard(
                    title: "Password",
                    icon: "key",
                    footer: "Enter your password to confirm it's you."
                ) {
                    SecureField("Password", text: $viewModel.password)
                        .font(.system(size: 16))
                        .textContentType(.password)
                        .focused($passwordFocused)
                        .submitLabel(.done)
                }

                if let message = viewModel.errorMessage {
                    ProfileErrorBanner(message: message)
                }

                Button {
                    passwordFocused = false
                    confirming = true
                } label: {
                    Group {
                        if viewModel.isDeleting {
                            ProgressView().tint(Color.white)
                        } else {
                            Text("Delete My Account")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.canDelete || viewModel.isDeleting ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(viewModel.canDelete || viewModel.isDeleting ? Color.red : Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canDelete)
                .animation(.easeInOut(duration: 0.15), value: viewModel.canDelete)
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isDeleting)
        .alert("Delete your account?", isPresented: $confirming) {
            Button("Delete", role: .destructive) { Task { await viewModel.delete() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Everything listed will be deleted for good. This can't be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        DeleteAccountScreen(viewModel: DeleteAccountViewModel(deleter: PreviewAccountDeleter()))
    }
}
