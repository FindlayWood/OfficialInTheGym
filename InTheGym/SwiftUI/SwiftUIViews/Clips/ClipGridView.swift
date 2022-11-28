//
//  ClipGridView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 28/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct ClipGridView: View {
    @State var thumbnail: UIImage?
    @State var profilePicture: UIImage?
    var clipModel: ClipModel
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .frame(height: 200)
                    .scaledToFill()
                    .clipped()
            } else {
                Color(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }
            if let profilePicture {
                Image(uiImage: profilePicture)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .scaledToFill()
                    .clipShape(Circle())
                    .padding()
            } else {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
            }
        }
        .cornerRadius(8)
        .onAppear {
            loadImage()
        }
    }
    func loadImage() {
        let profileImageModel = ProfileImageDownloadModel(id: clipModel.userID)
        ImageCache.shared.load(from: profileImageModel) { result in
            let image = try? result.get()
            profilePicture = image
        }
        
        let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: clipModel.id)
        ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { result in
            let image = try? result.get()
            thumbnail = image
        }
    }
}
