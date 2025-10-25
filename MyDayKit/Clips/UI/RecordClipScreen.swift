//
//  RecordClipScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/09/2025.
//

import SwiftUI

struct RecordClipScreen: View {
    @StateObject private var recorder = VideoRecorder()
    
    @State private var countDownOn: Bool = false
    @State private var countDown: Int?
    @State private var recordedURL: URL?
    
    var clipPlayback: ((URL) -> ())?
    var dismiss: (() -> ())?
    
    var body: some View {
        ZStack {
            if let url = recordedURL {
                LoopingVideoPlayer(url: url)
                    .ignoresSafeArea()
                
                PlaybackOverlay(
                    dismiss: {
                        recordedURL = nil
                        recorder.configure()
                    },
                    save: {
                        
                    }
                )
//                VStack {
//                    Spacer()
//                    HStack {
//                        Button("Retry") {
//                            recordedURL = nil
//                            recorder.configure()
//                        }
//                        .padding()
//                        .background(Color.red.opacity(0.7))
//                        .clipShape(Capsule())
//                        
//                        Button("Use Video") {
//                            // Do something with recordedURL (save/upload)
//                            dismiss?()
//                        }
//                        .padding()
//                        .background(Color.green.opacity(0.7))
//                        .clipShape(Capsule())
//                    }
//                    .padding(.bottom, 40)
//                }
            } else {
                CameraPreview(session: recorder.session)
                    .ignoresSafeArea()
                
                RecordingOverlay(
                    isRecording: recorder.isRecording,
                    flipCamera: recorder.flipCamera,
                    startRecording: recorder.startRecording,
                    stopRecording: recorder.stopRecording,
                    dismiss: dismiss
                )
            }
        }
        .onAppear {
            recorder.configure()
            recorder.onRecordingFinished = { url in
                self.recordedURL = url
            }
        }
    }
    

}

#Preview {
    RecordClipScreen()
}


