//
//  VideoRecorder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import AVFoundation
import Combine
import UniformTypeIdentifiers

public class VideoRecorder: NSObject, ObservableObject {
    
    @Published var recordingDuration: Double = 0
    @Published var recordingProgress: Double = 0
    @Published var isRecording = false
    @Published var isBelowMinimumDuration = true  // new — drives UI to disable stop button

    private var recordingTimer: Timer?
    private let maxRecordingDuration: Double = 16
    private let minimumRecordingDuration: Double = 5

    private(set) var lastRecordedURL: URL?
    
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var videoInput: AVCaptureDeviceInput?
    var onRecordingFinished: ((URL) -> ())?
    var onMinimumDurationNotMet: (() -> ())?  // new — callback to show user feedback

    func configure() {
        session.beginConfiguration()
        
        if let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) {
            addCameraInput(camera)
        }
        
        if let mic = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
            // Only set max duration here — AVFoundation owns the hard stop
            movieOutput.maxRecordedDuration = CMTime(
                seconds: maxRecordingDuration,
                preferredTimescale: 600
            )
        }
        
        session.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    // MARK: - Camera Flip
    
    func flipCamera() {
        guard let newCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentCameraPosition == .back ? .front : .back
        ) else { return }
        
        session.beginConfiguration()
        if let videoInput = videoInput {
            session.removeInput(videoInput)
        }
        addCameraInput(newCamera)
        session.commitConfiguration()
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
    }
    
    private func addCameraInput(_ camera: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
                self.videoInput = input
            }
        } catch {
            print("Error adding camera input: \(error)")
        }
    }
    
    // MARK: - Recording
    
    func startRecording() {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mov")
        
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true
        isBelowMinimumDuration = true
        
        startRecordingTimer()
    }
    
    func stopRecording() {
        // Enforce minimum duration — don't stop if under 5 seconds
        guard recordingDuration >= minimumRecordingDuration else {
            onMinimumDurationNotMet?()
            return
        }
        
        // Tell AVFoundation to stop — UI cleanup happens in the delegate
        movieOutput.stopRecording()
    }
    
    // MARK: - Timer
    // The timer is purely for UI progress updates.
    // It never calls stopRecording() — AVFoundation owns that responsibility.
    private func startRecordingTimer() {
        recordingDuration = 0
        recordingProgress = 0
        recordingTimer?.invalidate()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.recordingDuration += 0.05
            self.recordingProgress = min(
                self.recordingDuration / self.maxRecordingDuration,
                1.0
            )

            // Unlock the stop button once minimum is reached
            if self.recordingDuration >= self.minimumRecordingDuration {
                self.isBelowMinimumDuration = false
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    // MARK: - Discard
    
    func discardRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
        
        stopRecordingTimer()
        
        if let url = lastRecordedURL {
            do {
                try FileManager.default.removeItem(at: url)
                print("🗑 Deleted temp video")
            } catch {
                print("❌ Failed to delete video: \(error)")
            }
        }
        
        lastRecordedURL = nil
        recordingDuration = 0
        recordingProgress = 0
        isRecording = false
        isBelowMinimumDuration = true
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        // AVFoundation has fully finished — now safe to clean up
        stopRecordingTimer()
        isRecording = false
        isBelowMinimumDuration = true

        if let error = error {
            // AVFoundation can pass an error AND a valid file if it hit maxRecordedDuration
            // Check the file exists and has content before treating it as a failure
            let fileExists = FileManager.default.fileExists(atPath: outputFileURL.path)
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: outputFileURL.path)[.size] as? Int) ?? 0
            
            if !fileExists || fileSize == 0 {
                print("❌ Recording failed: \(error)")
                return
            }
            
            // File is valid despite the error (hit max duration) — fall through
            print("⚠️ Recording ended with non-fatal error (likely hit max duration): \(error)")
        }
        
        lastRecordedURL = outputFileURL
        print("✅ Video saved at: \(outputFileURL)")
        
        DispatchQueue.main.async {
            self.onRecordingFinished?(outputFileURL)
        }
    }
}
