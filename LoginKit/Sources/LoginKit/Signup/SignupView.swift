//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import SwiftUI

struct SignupView: View {
    
    @ObservedObject var viewModel: SignupViewModel
    
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
                
                if viewModel.emailInUse {
                    Text("An account with this email already exists.")
                        .font(.footnote.bold())
                        .foregroundColor(.red)
                }
                
                if viewModel.error != nil {
                    Text("There was an error creating your account. Please try again.")
                        .font(.footnote.bold())
                        .foregroundColor(.red)
                }
                
                Button {
                    Task {
                        await viewModel.signup()
                    }
                } label: {
                    Text("Sign Up")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(colour).opacity(viewModel.canSignup ? 1 : 0.3))
                        .clipShape(Capsule())
                        .shadow(radius: viewModel.canSignup ? 4 : 0)
                        
                }
                .disabled(!viewModel.canSignup)
                
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

struct SwiftUIView_Previews: PreviewProvider {
    struct PreviewNetworkService: NetworkService {
        func login(with email: String, password: String) async throws {}
        func signup(with email: String, password: String) async throws {}
        func forgotPassword(for email: String) async throws {}
    }
    static var previews: some View {
        SignupView(viewModel: SignupViewModel(networkService: PreviewNetworkService(),completion: {}), colour: .blue)
    }
}
