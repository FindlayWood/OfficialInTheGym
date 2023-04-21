//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import SwiftUI

struct WelcomeView: View {
    
    var colour: UIColor
    
    var image: UIImage
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome")
                .font(.title.bold())
                .foregroundColor(.primary)
            Text("Thanks for signing up and verifying your email. Now it's time to set up your account.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
            Spacer()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(colour: .blue, image: UIImage(systemName: "person")!)
    }
}
