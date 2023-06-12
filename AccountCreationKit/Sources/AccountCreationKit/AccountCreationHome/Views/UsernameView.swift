//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import SwiftUI

struct UsernameView: View {
    
    @ObservedObject var viewModel: AccountCreationHomeViewModel
    
    var colour: UIColor
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Username")
                .font(.title.bold())
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "person.crop.square.fill")
                    .foregroundColor(Color(colour))
                TextField("username", text: $viewModel.username)
                    .tint(Color(.blue))
                switch viewModel.isUsernameValid {
                case .checking:
                    ProgressView()
                case .tooShort, .taken, .invalid:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundColor(.red)
                case .valid:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundColor(.green)
                case .idle:
                    EmptyView()
                }
            }
            .padding()
            .background(.white)
            .clipShape(Capsule())
            .shadow(radius: 8)
            
            switch viewModel.isUsernameValid {
            case .checking, .valid, .idle:
                EmptyView()
            case .tooShort:
                Text("Username is too short.")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
            case .taken:
                Text("This username is already taken.")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
            case .invalid:
                Text("This username is invalid.")
                    .font(.footnote.bold())
                    .foregroundColor(.red)
            }
            
            Text("Enter your username above. Your username must be unique and is a way to identify yourself to other users in the app.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            Spacer()
        }
        .padding()
    }
}

struct UsernameView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameView(viewModel: AccountCreationHomeViewModel(email: "", uid: "", callback: {}), colour: .blue)
    }
}
