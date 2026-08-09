//
//  ProfileSummaryStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct ProfileSummaryStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Profile")
                .font(.title.bold())
                .foregroundColor(.primary)

            VStack(alignment: .center) {
                if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .clipShape(Circle())
                        .padding()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .padding()
                }

                Text(viewModel.displayName)
                    .font(.title3.bold())
                Text("@\(viewModel.username)")
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.bottom)

                VStack(spacing: 0) {
                    Image(systemName: "figure.run")
                    Text(viewModel.selectedAccountType?.title ?? "Select Account Type")
                }
                .padding(.bottom)

                Text(viewModel.bio)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }

            Spacer()

            VStack(alignment: .leading) {
                if viewModel.isUsernameValid != .valid {
                    Text("Please enter a valid username.")
                }
                if viewModel.displayName.isEmpty {
                    Text("Please enter a display name.")
                }
                if viewModel.selectedAccountType == nil {
                    Text("Please select an account type.")
                }
            }
            .foregroundColor(.red)
            .font(.footnote.bold())
        }
        .padding()
    }
}

#Preview {
    ProfileSummaryStepView(viewModel: .preview)
}
