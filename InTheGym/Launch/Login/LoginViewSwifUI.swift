//
//  LoginViewSwifUI.swift
//  InTheGym
//
//  Created by Findlay-Personal on 04/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct LoginViewSwifUI: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var showingPassword: Bool = false
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color(.darkColour))
                    TextField("email", text: $viewModel.email)
                        .tint(Color(.darkColour))
                }
                .padding()
                .background(.white)
                .clipShape(Capsule())
                .shadow(radius: 8)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color(.darkColour))
                    if showingPassword {
                        TextField("password", text: $viewModel.password)
                            .tint(Color(.darkColour))
                    } else {
                        SecureField("password", text: $viewModel.password)
                            .tint(Color(.darkColour))
                    }
                    Button {
                        showingPassword.toggle()
                    } label: {
                        Image(systemName: showingPassword ? "eye" : "eye.slash")
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(.white)
                .clipShape(Capsule())
                .shadow(radius: 8)
                
                
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    Text("Log In")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(.darkColour).opacity(viewModel.canLogin ? 1 : 0.3))
                        .clipShape(Capsule())
                        .shadow(radius: viewModel.canLogin ? 4 : 0)
                        
                }
                .disabled(!viewModel.canLogin)
                
                Button {
                    viewModel.forgotPassword.send(true)
                } label: {
                    Text("FORGOT PASSWORD")
                        .font(.footnote.bold())
                        .foregroundColor(Color(.darkColour))
                }
                .padding()
                Spacer()
            }
            .padding()
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .background(Color(.systemBackground))
    }
}

struct LoginViewSwifUI_Previews: PreviewProvider {
    static var previews: some View {
        LoginViewSwifUI(viewModel: LoginViewModel())
    }
}
