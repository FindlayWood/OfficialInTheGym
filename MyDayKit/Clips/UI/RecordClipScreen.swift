//
//  RecordClipScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/09/2025.
//

import SwiftUI

struct RecordClipScreen: View {
    
    @StateObject private var recorder = VideoRecorder()
    
    @ObservedObject var uploadManager: UploadManager
    
    @State private var recordedURL: URL?
    @State private var processing: Bool = false
    @State private var processedVideo: ProcessedVideoData?
    
    @State private var dismissRecordedVideo: Bool = false
    
    @State private var isVideoPlaying: Bool = true
    @State private var playbackProgress: Double = 0
    
    @State private var showUploadProgress: Bool = false
    
    @State private var showOptionsSheet = false
    @State var videoPublic: Bool = true
    
    let videoConverter: VideoConverter
    let myDayManager: MyDayManager
    let exerciseID: String
    
    var clipPlayback: ((URL) -> ())?
    var dismiss: (() -> ())?
    var uploadComplete: (() -> ())?
    
    var body: some View {
        
        Group {
            if let processedVideo {
                ZStack {
                    ClipPlaybackScreen(
                        isVideoPlaying: $isVideoPlaying,
                        playbackProgress: $playbackProgress,
                        processedVideo: processedVideo,
                        didTapOptions: {
                            showOptionsSheet.toggle()
                        },
                        dismissRecordedVideo: {
                            dismissRecordedVideo.toggle()
                        }, didTapUpload: {
                            beginUpload(processedVideo.clipData)
                        }
                    )
                    
                    if showUploadProgress {
                        UploadProgressView(
                            state: uploadManager.state,
                            canCancel: uploadManager.canCancel,
                            onComplete: { result in
                                uploadComplete(result)
                            },
                            cancelUpload: {
                                showUploadProgress = false
                            },
                            onDismiss: {
                                showUploadProgress = false
                                
                            }
                        )
                    }
                }
            } else {
                ZStack {
                    CameraPreview(session: recorder.session)
                        .ignoresSafeArea()
                    
                    RecordingOverlay(
                        isRecording: recorder.isRecording,
                        recordingProgress: recorder.recordingProgress,
                        recordingDuration: recorder.recordingDuration,
                        isBelowMinimumDuration: recorder.isBelowMinimumDuration,
                        flipCamera: recorder.flipCamera,
                        startRecording: recorder.startRecording,
                        stopRecording: recorder.stopRecording,
                        dismiss: dismiss
                    )
                    
                    if processing {
                        Color.black.opacity(0.6).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
        }
        .onAppear {
            recorder.configure()
            recorder.onRecordingFinished = { url in
                self.beginProcessing(url)
                self.recordedURL = url
            }
        }
        .sheet(isPresented: $dismissRecordedVideo) {
            ZStack {
                // Background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(Color.red)
                    }
                    .padding(.top, 36)
                    .padding(.bottom, 20)
                    
                    // Title
                    Text("Discard Recording?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    
                    // Subtitle
                    Text("This clip will be permanently deleted.\nYou can't undo this action.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.top, 8)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 10) {
                        Button {
                            recorder.discardRecording()
                            recordedURL = nil
                            processedVideo = nil
                            dismissRecordedVideo = false
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Delete Recording")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Button {
                            dismissRecordedVideo = false
                        } label: {
                            Text("Keep Recording")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(UIColor.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
        }
        .sheet(
            isPresented: $showOptionsSheet,
            onDismiss: {
                isVideoPlaying = true
            }) {
                PlayBackSheet(
                    videoPublic: $videoPublic,
                    upload: {
                        
                    },
                    saveToCameraRoll: {
                        
                    }
                )
            }
    }
    
    func beginProcessing(_ with: URL) {
        processing = true
        Task {
            do {
                let processedData = try await videoConverter.buildClipUploadData(from: with, exerciseID: exerciseID, isPrivate: !videoPublic)
                processedVideo = ProcessedVideoData(url: with, clipData: processedData)
                processing = false
                print("processed video")
            } catch {
                processing = false
            }
            
        }
    }
    
    func beginUpload(_ data: ClipUploadData) {
        showUploadProgress = true
        uploadManager.startUpload(uploadData: data)
    }
    
    func uploadComplete(_ result: ClipUploadResult) {
        myDayManager.addClipData(result)
        uploadComplete?()
    }
}

#Preview {
    RecordClipScreen(
        uploadManager: UploadManager(
            clipUploader: MockClipUploader()
        ),
        videoConverter: VideoConverter(
            userID: "user123",
            thumbnailGenerator: MockThumbnailGenerator()
        ),
        myDayManager: MyDayManager(
            saver: PreviewSaver(),
            clipSaver: PreviewMyDaySaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: PreviewLoader(),
            deleter: PreviewMyDayDeleter(),
            wellnessSaver: PreviewMyDaySaver(),
            rpeSaver: PreviewMyDaySaver()
        ),
        exerciseID: "exerciseID"
    )
}
