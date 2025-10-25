//
//  VideoRecorder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import AVFoundation

class VideoRecorder: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var videoInput: AVCaptureDeviceInput?
    var onRecordingFinished: ((URL) -> Void)?
    
    @Published var isRecording = false
    
    func configure() {
        session.beginConfiguration()
        
        // Setup initial camera (back)
        if let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) {
            addCameraInput(camera)
        }
        
        // Microphone
        if let mic = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        // Output
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
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
        ) else {
            return
        }
        
        session.beginConfiguration()
        
        // Remove old input
        if let videoInput = videoInput {
            session.removeInput(videoInput)
        }
        
        // Add new input
        addCameraInput(newCamera)
        
        session.commitConfiguration()
        
        // Update position
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
    
    func startRecording() {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mov")
        
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        movieOutput.stopRecording()
        isRecording = false
    }
}

extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Recording error: \(error)")
            return
        }
        
        print("Video saved at: \(outputFileURL)")
        DispatchQueue.main.async {
            self.onRecordingFinished?(outputFileURL)
        }
    }
}

import Photos

extension VideoRecorder {
    func saveVideoToPhotos(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                completion(false, NSError(domain: "Permission", code: 1, userInfo: [NSLocalizedDescriptionKey: "No photo library access"]))
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
}

import AVFoundation
import UIKit

extension VideoRecorder {

    func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true // keeps orientation correct
        
        let time = CMTime(seconds: 0, preferredTimescale: 600) // first frame
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("❌ Thumbnail error: \(error)")
            return nil
        }
    }
}
