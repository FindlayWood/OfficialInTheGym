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
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    CustomTextField(text: $viewModel.firstName, placeholder: "first name...")
                    CustomTextField(text: $viewModel.lastName, placeholder: "last name...")
                    CustomTextField(text: $viewModel.email, placeholder: "email...")
                    CustomTextField(text: $viewModel.username, placeholder: "username...")
                    CustomTextField(text: $viewModel.password, placeholder: "password...")
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
