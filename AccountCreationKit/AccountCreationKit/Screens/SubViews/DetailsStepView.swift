//
//  DetailsStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Display name and username together — two single-line required fields that used to be a step
/// each, which made the flow feel longer without asking anything more.
///
/// Display name comes first: it is the friendlier question, and it has no validation to fail.
struct DetailsStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    private enum Field: Hashable {
        case displayName
        case username
    }

    @FocusState private var focused: Field?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                AccountCreationStepHeader(step: .details)

                // MARK: Display Name
                AccountCreationFieldCard(
                    title: "Display Name",
                    icon: "person.crop.square",
                    counter: "\(viewModel.displayName.count)/\(viewModel.displayNameLimit)"
                ) {
                    TextField("Your name", text: $viewModel.displayName)
                        .font(.system(size: 16))
                        .tint(Color.darkColor)
                        .focused($focused, equals: .displayName)
                        .submitLabel(.next)
                        .onSubmit { focused = .username }
                }

                // MARK: Username
                AccountCreationFieldCard(
                    title: "Username",
                    icon: "at",
                    counter: "\(viewModel.username.count)/\(viewModel.usernameLimit)",
                    footer: footer
                ) {
                    HStack(spacing: 8) {
                        TextField("username", text: $viewModel.username)
                            .font(.system(size: 16))
                            .tint(Color.darkColor)
                            .keyboardType(.asciiCapable)
                            // Without this iOS capitalises the first letter, and the field then
                            // reserves a name the user never typed. The view model lowercases too,
                            // for pastes.
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .focused($focused, equals: .username)
                            .submitLabel(.done)
                            .onSubmit { focused = nil }

                        statusIcon
                    }
                }

                Text("Your username is how people find you. Your display name is what they'll see.")
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
    }

    /// The reservation clash message wins over the validity message — it is the more recent and more
    /// specific thing that happened to this username.
    private var footer: AccountCreationFieldFooter? {
        if let usernameError = viewModel.usernameError {
            return .init(message: usernameError, isError: true)
        }
        if let message = viewModel.isUsernameValid.message {
            return .init(message: message, isError: true)
        }
        return nil
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch viewModel.isUsernameValid {
        case .checking:
            ProgressView()
                .controlSize(.small)
        case .tooShort, .taken, .invalid, .unchecked:
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.red)
        case .valid:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.green)
        case .idle:
            EmptyView()
        }
    }
}

#Preview {
    DetailsStepView(viewModel: .preview)
}
