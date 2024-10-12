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
        VStack {
            Text("Account Created")
                .font(.title.bold())
                .foregroundColor(.primary)
            Image(systemName: "person.crop.circle.badge.checkmark")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 100)
                .foregroundColor(Color(.darkColour))
                .padding()
            Text("Your account has been created. You just need to verify your email.")
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
            Text("We have sent an email to \(viewModel.user?.email ?? "email"). \n Tap the link in the email to verify your account. We require verififying your account as an extra safety step for us and for you.")
                .foregroundColor(.secondary)
                .font(.footnote.bold())
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                viewModel.resendVerificationEmailAction()
            } label: {
                Text("Resend Verification Email")
                    .font(.headline)
                    .foregroundColor(Color(.darkColour))
            }.padding()
            Button {
                viewModel.logoutAction()
            } label: {
                Text("Sign Out")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

struct VerifyAccountView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyAccountView(viewModel: VerifyAccountViewModel())
    }
}
