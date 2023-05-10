//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 09/04/2023.
//

import PhotosUI
import SwiftUI

struct ProfilePictureView: View {
    
    @ObservedObject var viewModel: AccountCreationHomeViewModel
    
    @State private var showingImagePicker: Bool = false
    
    var colour: UIColor
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Profile Picture")
                .font(.title.bold())
            Text("Select a profile picture")
                .font(.footnote.bold())
                .foregroundColor(.secondary)

            VStack(alignment: .center) {
                if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .clipShape(Circle())
                        .padding()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .padding()
                }
                PhotosPicker("Select Photo", selection: $avatarItem, matching: .any(of: [.images, .not(.videos)]))
                    .font(.headline)
                    .foregroundColor(Color(colour))
            }
            Spacer()
        }
        .padding()
        .onChange(of: avatarItem) { _ in
            Task {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        viewModel.profileImage = uiImage
                        avatarImage = Image(uiImage: uiImage)
                        return
                    }
                }

                print("Failed")
            }
        }
    }
}

struct ProfilePictureView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureView(viewModel: AccountCreationHomeViewModel(email: "", uid: ""), colour: .blue)
    }
}

