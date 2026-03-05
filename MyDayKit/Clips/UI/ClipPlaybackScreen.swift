//
//  ClipPlaybackScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import SwiftUI

struct ClipPlaybackScreen: View {
    
    @Binding var isVideoPlaying: Bool
    @Binding var playbackProgress: Double
    
    let processedVideo: ProcessedVideoData
    
    var didTapOptions: (() -> ())?
    var dismissRecordedVideo: (() -> ())?
    var didTapUpload: (() -> ())?
    
    var body: some View {
        ZStack {
            LoopingVideoPlayer(
                url: processedVideo.url,
                isPlaying: $isVideoPlaying,
                progress: $playbackProgress
            )
            .ignoresSafeArea()
            .onTapGesture {
                isVideoPlaying.toggle()
            }
            
            PlaybackOverlay(
                progress: playbackProgress,
                isPlaying: isVideoPlaying,
                options: {
                    didTapOptions?()
                },
                dismiss: {
                    dismissRecordedVideo?()
                },
                upload: {
                    didTapUpload?()
                }
            )
        }
    }
}


#Preview {
    ClipPlaybackScreen(
        isVideoPlaying: .constant(true),
        playbackProgress: .constant(50),
        processedVideo: ProcessedVideoData(
            url: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!,
            clipData: ClipUploadData(
                videoData: .init(),
                thumbnailData: nil,
                userID: "user",
                clipID: "clipid",
                exerciseID: "exerciseID",
                isPrivate: true,
                videoMetadata: ClipUploadData.VideoMetadata(
                    contentType: "content-type",
                    duration: TimeInterval(),
                    width: 10,
                    height: 10,
                    fileSize: 1,
                    codec: "codec"
                )
            )
        )
    )
}
