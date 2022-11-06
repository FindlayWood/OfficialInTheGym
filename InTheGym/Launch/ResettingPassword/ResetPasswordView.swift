//
//  ResetPasswordView.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var viewModel: ResettingPasswordViewModel
    var body: some View {
        ZStack {
            VStack {
                CustomTextField(text: $viewModel.email, placeholder: "enter email...")
                    .padding(.top)
                Button {
                    viewModel.sendButtonAction()
                } label: {
                    Text("Send Email")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(.darkColour).opacity(viewModel.isEmailValid ? 1 : 0.3))
                        .clipShape(Capsule())
                        .shadow(radius: viewModel.isEmailValid ? 4 : 0)
                        
                }
                .disabled(!viewModel.isEmailValid)
                .padding(.vertical)
                Text("You will be sent an email in which you can enter a new password.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(viewModel: ResettingPasswordViewModel())
    }
}
