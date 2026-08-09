//
//  LoginView.swift
//  LoginKit
//
//  Created by Findlay-Personal on 03/04/2023.
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var viewModel: LoginViewModel

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

                        LoginFieldCard(title: "Password", icon: "lock") {
                            PasswordField(
                                placeholder: "Your password",
                                password: $viewModel.password,
                                contentType: .password
                            )
                            .focused($focused, equals: .password)
                        }

                        if viewModel.error != nil {
                            LoginErrorBanner(message: "That email and password don't match an account. Check them and try again.")
                        }

                        Button {
                            viewModel.forgotPasswordAction()
                        } label: {
                            Text("Forgot password?")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.darkColor)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                VStack(spacing: 0) {
                    Divider()
                    LoginPrimaryButton(title: "Log In", isEnabled: viewModel.canLogin) {
                        Task { await viewModel.login() }
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
    return LoginView(viewModel: LoginViewModel(networkService: PreviewNetworkService(), completion: {}))
}
