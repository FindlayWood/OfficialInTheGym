//
//  UsernameStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct UsernameStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Username")
                .font(.title.bold())
                .foregroundColor(.primary)

            HStack {
                Image(systemName: "person.crop.square.fill")
                    .foregroundColor(Color.darkColor)
                TextField("username", text: $viewModel.username)
                    .tint(Color.darkColor)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled(true)
                switch viewModel.isUsernameValid {
                case .checking:
                    ProgressView()
                case .tooShort, .taken, .invalid:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundColor(.red)
                case .valid:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundColor(.green)
                case .idle:
                    EmptyView()
                }
            }
            .padding()
            .background(.white)
            .clipShape(Capsule())
            .shadow(radius: 8)

            switch viewModel.isUsernameValid {
            case .checking, .valid, .idle:
                EmptyView()
            case .tooShort:
                Text("Username is too short.")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
            case .taken:
                Text("This username is already taken.")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
            case .invalid:
                Text("This username is invalid.")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
                Text("Usernames must only contain letters, numbers, _ or .")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
            }

            Text("Enter your username above. Your username must be unique and is a way to identify yourself to other users in the app.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
                .padding(.bottom)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    UsernameStepView(viewModel: .preview)
}
