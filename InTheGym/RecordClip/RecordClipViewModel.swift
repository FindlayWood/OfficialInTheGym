//
//  RecordClipViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

class RecordClipViewModel: NSObject {
    
    // MARK: - Publishers
    var outPutFilePublisher = PassthroughSubject<URL,Never>()
    
    // MARK: - Properties
    var captureSession: AVCaptureSession!
    
    var backCameraOn: Bool = true
    
    var countDownOn: Bool = false
    
    var backCamera: AVCaptureDevice!
    var frontCamera: AVCaptureDevice!
    
    var audio: AVCaptureDevice!
    
    var backCameraInput: AVCaptureInput!
    var frontCameraInput: AVCaptureInput!
    
    var videoOutput: AVCaptureMovieFileOutput!
    
    var workoutModel: WorkoutModel?
    
    var exerciseModel: DiscoverExerciseModel!
    
    var addingDelegate: ClipAdding!
    
    let maxVideoLength: Double = 16
    
    // MARK: - Methods
    func beginRecording() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: outputURL)
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    // MARK: - Capture Session
    func setUpCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        setUpDevices()
//        setUpPreviewLayer()
        setUpVideoOutput()
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    // MARK: - Set up Devices
    func setUpDevices() {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            fatalError("no back camera")
        }
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            fatalError("no front camera")
        }
        
        if let device = AVCaptureDevice.default(for: .audio) {
            audio = device
        } else {
            fatalError("no audio")
        }
        
        guard let backInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("could not create input device from back camera")
        }
        backCameraInput = backInput
        if !captureSession.canAddInput(backCameraInput) {
            fatalError("could not add back camera input to capture session")
        }
        
        guard let frontInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("could not create input device from front camera")
        }
        frontCameraInput = frontInput
        if !captureSession.canAddInput(frontCameraInput) {
            fatalError("could not add front camera input to capture session")
        }
        
        guard let audioCaptureInput = try? AVCaptureDeviceInput(device: audio) else {
            fatalError("could not create input device from microphone")
        }
        
        if !captureSession.canAddInput(audioCaptureInput) {
            fatalError("could not add audio to the capture session")
        }
        
        captureSession.addInput(audioCaptureInput)
        captureSession.addInput(backCameraInput)
    }
    
    // MARK: - Video OUtput
    func setUpVideoOutput() {
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }
}

// MARK: - Camera recording output delegate
extension RecordClipViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error)
        } else {
            outPutFilePublisher.send(outputFileURL)
        }
    }
}
