//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import SwiftUI

struct WelcomeView: View {
    
    var colour: UIColor
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome")
                .font(.title.bold())
                .foregroundColor(.primary)
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    VStack {
                        Image(systemName: "pencil.and.outline")
                            .foregroundColor(Color(colour))
                        Text("Account Setup")
                            .font(.title3.bold())
                            .padding(.bottom)
                        Text("Thanks for signing up and verifying your email. Now it's time to set up your account. Let other users know about you by entering some details.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    VStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(colour))
                        Text("Privacy")
                            .font(.title3.bold())
                            .padding(.bottom)
                        Text("You can make your account private if you do not want other users to see your any of your account activity. (Display name, username and profile picture will be visisble to all InTheGym user's, even for private accounts).")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    VStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(colour))
                        Text("Stamps")
                            .font(.title3.bold())
                            .padding(.bottom)
                        Text("InTheGym uses a stamp system to give you some more information about certain accounts. This helps users understand a bit more about where their information is coming from and if it is worthwhile and trustworthy. Accounts go through a strict verification process to gain stamps.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    VStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Color(colour))
                        Text("Premium")
                            .font(.title3.bold())
                            .padding(.bottom)
                        Text("You can make upgrade your account to premium to gain access to some amazing features. As well as the amazing extra features, premium accounts gain an extra badge next to their account. You can read all about the premium features and upgrade your account once you have completed setup.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }

        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(colour: .blue)
    }
}
