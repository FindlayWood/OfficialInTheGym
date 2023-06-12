//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import SwiftUI

struct DisplayNameView: View {
    @ObservedObject var viewModel: AccountCreationHomeViewModel
    
    var colour: UIColor
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Display Name")
                .font(.title.bold())
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "person.crop.square.fill")
                    .foregroundColor(Color(colour))
                TextField("display name", text: $viewModel.displayName)
                    .tint(Color(.blue))
            }
            .padding()
            .background(.white)
            .clipShape(Capsule())
            .shadow(radius: 8)
            
            Text("Enter your display name above. We recommend just using your real name.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            Spacer()
        }
        .padding()
    }
}

struct DisplayNameView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayNameView(viewModel: AccountCreationHomeViewModel(email: "", uid: "", callback: {}), colour: .blue)
    }
}
