//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 04/04/2023.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @ObservedObject var viewModel: ForgotPasswordViewModel
    
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
                
                
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    Text("Send Reset Email")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(colour).opacity(viewModel.canReset ? 1 : 0.3))
                        .clipShape(Capsule())
                        .shadow(radius: viewModel.canReset ? 4 : 0)
                        
                }
                .disabled(!viewModel.canReset)
                
                Text("If you have forgotten your password don't worry, we will send an email allowing you to reset your password. Enter the email address that you created your account with above so we can send you the email.")
                    .font(.caption.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
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

struct ForgotPasswordView_Previews: PreviewProvider {
    struct PreviewNetworkService: NetworkService {
        func login(with email: String, password: String) async throws {}
        func signup(with email: String, password: String) async throws {}
        func forgotPassword(for email: String) async throws {}
    }
    static var previews: some View {
        ForgotPasswordView(viewModel: ForgotPasswordViewModel(networkService: PreviewNetworkService()), colour: .blue)
    }
}
