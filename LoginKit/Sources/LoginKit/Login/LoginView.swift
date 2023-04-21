//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    
    @State private var showingPassword: Bool = false
    
    var colour: UIColor
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color(colour))
                    TextField("email", text: $viewModel.email)
                        .tint(Color(.blue))
                }
                .padding()
                .background(.white)
                .clipShape(Capsule())
                .shadow(radius: 8)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color(colour))
                    if showingPassword {
                        TextField("password", text: $viewModel.password)
                            .tint(Color(colour))
                    } else {
                        SecureField("password", text: $viewModel.password)
                            .tint(Color(colour))
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
                
                if viewModel.error != nil {
                    Text("Invalid login credentials. Please try again.")
                        .font(.footnote.bold())
                        .foregroundColor(.red)
                }
                
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
                        .background(Color(colour).opacity(viewModel.canLogin ? 1 : 0.3))
                        .clipShape(Capsule())
                        .shadow(radius: viewModel.canLogin ? 4 : 0)
                        
                }
                .disabled(!viewModel.canLogin)
                
                Button {
                    viewModel.forgotPasswordAction()
                } label: {
                    Text("FORGOT PASSWORD")
                        .font(.footnote.bold())
                        .foregroundColor(Color(colour))
                }
                .padding()
                Spacer()
            }
            .padding()
            
            if viewModel.isLoading {
                LoadingView(colour: colour)
            }
        }
        .background(Color(.systemBackground))

    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(coordinator: nil), colour: .blue)
    }
}
