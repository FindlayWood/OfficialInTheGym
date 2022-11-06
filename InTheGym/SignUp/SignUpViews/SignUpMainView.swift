//
//  SignUpMainView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 04/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SignUpMainView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @State private var accountType: Bool = false
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    CustomTextField(text: $viewModel.firstName, image: "person.fill", placeholder: "first name...")
                    CustomTextField(text: $viewModel.lastName, image: "person.fill", placeholder: "last name...")
                    CustomTextFieldWithCheck(text: $viewModel.email, state: $viewModel.emailValid, errorMessage: "Invalid Email", image: "envelope.fill", placeholder: "email...")
                    CustomTextFieldWithCheck(text: $viewModel.username, state: $viewModel.usernameValid, errorMessage: "This username is already taken.", image: "tag.fill", placeholder: "username...")
                    CustomSecureTextField(text: $viewModel.password, state: $viewModel.passwordValid, placeholder: "password...")
                    Button {
                        viewModel.signUpButtonPressed()
                    } label: {
                        Text("Sign Up")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour).opacity(viewModel.canSignUp ? 1 : 0.3))
                            .clipShape(Capsule())
                            .shadow(radius: viewModel.canSignUp ? 4 : 0)
                            
                    }
                    .disabled(!viewModel.canSignUp)
                    .padding(.vertical)
                }
                .padding([.horizontal, .top])
            }
            VStack {
                Spacer()
                Text("2 of 2")
                    .font(.footnote.bold())
                    .foregroundColor(Color(.darkColour))
                Text("INTHEGYM")
                    .font(.footnote.bold())
                    .foregroundColor(Color(.darkColour))
            }
            .frame(maxHeight: .infinity)
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SignUpMainView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpMainView(viewModel: SignUpViewModel())
    }
}
