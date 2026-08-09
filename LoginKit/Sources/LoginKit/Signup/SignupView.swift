//
//  SignupView.swift
//  LoginKit
//
//  Created by Findlay-Personal on 03/04/2023.
//

import SwiftUI

struct SignupView: View {

    @ObservedObject var viewModel: SignupViewModel

    private enum Field: Hashable {
        case email
        case password
    }

    @FocusState private var focused: Field?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        LoginFieldCard(title: "Email", icon: "envelope") {
                            TextField("you@example.com", text: $viewModel.email)
                                .font(.system(size: 16))
                                .tint(Color.darkColor)
                                .keyboardType(.emailAddress)
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .focused($focused, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focused = .password }
                        }

                        // The rule is stated rather than left to be discovered by a button that
                        // stays greyed out with nothing saying why.
                        LoginFieldCard(
                            title: "Password",
                            icon: "lock",
                            footer: "At least 6 characters."
                        ) {
                            PasswordField(
                                placeholder: "Choose a password",
                                password: $viewModel.password,
                                contentType: .newPassword
                            )
                            .focused($focused, equals: .password)
                        }

                        if viewModel.emailInUse {
                            LoginErrorBanner(message: "An account with this email already exists. Try logging in instead.")
                        } else if viewModel.error != nil {
                            LoginErrorBanner(message: "We couldn't create your account. Check your connection and try again.")
                        }

                        Text("You'll get a verification email to confirm this address before you can finish setting up.")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                VStack(spacing: 0) {
                    Divider()
                    LoginPrimaryButton(title: "Sign Up", isEnabled: viewModel.canSignup) {
                        Task { await viewModel.signup() }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
            }

            if viewModel.isLoading {
                LoadingView()
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    struct PreviewNetworkService: NetworkService {
        func login(with email: String, password: String) async throws {}
        func signup(with email: String, password: String) async throws {}
        func forgotPassword(for email: String) async throws {}
    }
    return SignupView(viewModel: SignupViewModel(networkService: PreviewNetworkService(), completion: {}))
}
