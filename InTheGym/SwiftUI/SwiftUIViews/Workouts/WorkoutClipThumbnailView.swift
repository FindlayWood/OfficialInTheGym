//
//  WorkoutClipThumbnailView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 18/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct WorkoutClipThumbnailView: View {
    @State var firstClip: UIImage?
    @State var secondClip: UIImage?
    @State var thirdClip: UIImage?
    var models: [WorkoutClipModel]
    var body: some View {
        HStack {
            ZStack {
                if let thirdClip {
                    Image(uiImage: thirdClip)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(.offWhiteColour), lineWidth: 2)
                        }
                        .offset(x: 60)
                        .padding(.trailing, 60)
                }
                if let secondClip {
                    Image(uiImage: secondClip)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(.offWhiteColour), lineWidth: 2)
                        }
                        .offset(x: 30)
                        .padding(.trailing, 30)
                }
                if let firstClip {
                    Image(uiImage: firstClip)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(.offWhiteColour), lineWidth: 2)
                        }
                }
            }
            
            Text("Clips")
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
        }
        .onAppear {
            if let firstClip = models.first {
                let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: firstClip.clipKey)
                ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { result in
                    let image = try? result.get()
                    self.firstClip = image
                }
            }
            if models.count > 1 {
                let secondClip = models[1]
                let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: secondClip.clipKey)
                ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { result in
                    let image = try? result.get()
                    self.secondClip = image
                }
            }
            if models.count > 2 {
                let thirdClip = models[2]
                let thumbnailDownloadModel = ClipThumbnailDownloadModel(id: thirdClip.clipKey)
                ImageCache.shared.loadThumbnail(from: thumbnailDownloadModel) { result in
                    let image = try? result.get()
                    self.thirdClip = image
                }
            }
        }
    }
}
