//
//  WelcomeStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct WelcomeStepView: View {

    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome")
                .font(.title.bold())
                .foregroundColor(.primary)
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    card(
                        icon: "pencil.and.outline",
                        title: "Account Setup",
                        message: "Thanks for signing up and verifying your email. Now it's time to set up your account. Let other users know about you by entering some details."
                    )
                    card(
                        icon: "lock.fill",
                        title: "Privacy",
                        message: "You can make your account private if you do not want other users to see your any of your account activity. (Display name, username and profile picture will be visisble to all InTheGym user's, even for private accounts)."
                    )
                    card(
                        icon: "checkmark.seal.fill",
                        title: "Stamps",
                        message: "InTheGym uses a stamp system to give you some more information about certain accounts. This helps users understand a bit more about where their information is coming from and if it is worthwhile and trustworthy. Accounts go through a strict verification process to gain stamps."
                    )
                    card(
                        icon: "crown.fill",
                        title: "Premium",
                        message: "You can make upgrade your account to premium to gain access to some amazing features. As well as the amazing extra features, premium accounts gain an extra badge next to their account. You can read all about the premium features and upgrade your account once you have completed setup."
                    )
                }
            }
        }
        .padding()
    }

    private func card(icon: String, title: String, message: String) -> some View {
        VStack {
            Image(systemName: icon)
                .foregroundColor(Color.darkColor)
            Text(title)
                .font(.title3.bold())
                .padding(.bottom)
            Text(message)
                .font(.footnote.bold())
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    WelcomeStepView()
}
