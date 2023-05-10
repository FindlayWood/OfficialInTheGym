//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 05/04/2023.
//

import SwiftUI

struct WelcomeView: View {
    
    @ObservedObject var viewModel: WelcomeViewModel
    
    var image: UIImage
    var colour: UIColor
    
    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: image)
                .resizable()
                .frame(maxWidth: .infinity)
                .aspectRatio(contentMode: .fit)
                .padding()
            
            Text(viewModel.title)
                .font(.largeTitle.bold())
                .foregroundColor(Color(colour))
            
            Spacer()
            
            Button {
                viewModel.signupAction()
            } label: {
                Text("Sign Up")
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color(colour))
                    .clipShape(Capsule())
                    .shadow(radius: 4)
            }
            
            HStack {
                Text("Already have an acccount?")
                Button {
                    viewModel.loginAction()
                } label: {
                    Text("LOGIN")
                        .font(.headline)
                        .foregroundColor(Color(colour))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: WelcomeViewModel(title: "INTHEGYM"), image: UIImage(systemName: "eraser.fill")!, colour: .blue)
    }
}
