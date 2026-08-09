//
//  ProfilePictureStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import PhotosUI
import SwiftUI

struct ProfilePictureStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    @State private var avatarItem: PhotosPickerItem?

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
                    .foregroundColor(Color.darkColor)
            }
            Spacer()
        }
        .padding()
        .onChange(of: avatarItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    viewModel.profileImage = uiImage
                    return
                }
                print("Failed")
            }
        }
    }
}

#Preview {
    ProfilePictureStepView(viewModel: .preview)
}
