//
//  ForgotPasswordView.swift
//  LoginKit
//
//  Created by Findlay-Personal on 04/04/2023.
//

import SwiftUI

struct ForgotPasswordView: View {

    @ObservedObject var viewModel: ForgotPasswordViewModel

    @FocusState private var emailFocused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("Enter the email you signed up with and we'll send you a link to reset your password.")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        LoginFieldCard(title: "Email", icon: "envelope") {
                            TextField("you@example.com", text: $viewModel.email)
                                .font(.system(size: 16))
                                .tint(Color.darkColor)
                                .keyboardType(.emailAddress)
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .focused($emailFocused)
                                .submitLabel(.done)
                                .onSubmit { emailFocused = false }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .scrollDismissesKeyboard(.interactively)

                VStack(spacing: 0) {
                    Divider()
                    LoginPrimaryButton(title: "Send Reset Email", isEnabled: viewModel.canReset) {
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
    return ForgotPasswordView(viewModel: ForgotPasswordViewModel(networkService: PreviewNetworkService()))
}
