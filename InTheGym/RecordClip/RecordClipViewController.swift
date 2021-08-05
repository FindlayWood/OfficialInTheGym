//
//  RecordClipViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class RecordClipViewController: UIViewController {
    
    var display = RecordClipView()
    
    var captureSession: AVCaptureSession!
    
    var backCamera: AVCaptureDevice!
    var frontCamera: AVCaptureDevice!
    
    var audio: AVCaptureDevice!
    
    var backCameraInput: AVCaptureInput!
    var frontCameraInput: AVCaptureInput!
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var videoOutput: AVCaptureMovieFileOutput!
    
    var backCameraOn: Bool = true
    
    var countDownOn: Bool = false
    
    var workoutID: String!
    var exercisePosition: Int!
    var exerciseName: String!
    
    var addingDelegate: addedClipProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCaptureSession()
        displaySetUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    
    func displaySetUp() {
        display.backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        display.flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        display.countDownButton.addTarget(self, action: #selector(toggleCountDown), for: .touchUpInside)
        display.videoLengthButton.addTarget(self, action: #selector(changeVideoLength), for: .touchUpInside)
        display.recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    func setUpCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
        captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        setUpDevices()
        setUpPreviewLayer()
        setUpVideoOutput()
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

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
    
    func setUpPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoPreviewLayer.frame = self.view.frame
        self.view.layer.insertSublayer(videoPreviewLayer, at: 0)
    }
    
    func switchCameraInput() {
        display.flipCameraButton.isUserInteractionEnabled = false
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
            backCameraOn = true
        }
        
        videoPreviewLayer.connection?.videoOrientation = .portrait
        captureSession.commitConfiguration()
        display.flipCameraButton.isUserInteractionEnabled = true
    }
    
    func setUpVideoOutput() {
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }
    
    @objc func recordButtonTapped() {
        if !videoOutput.isRecording {
            //check if countdown is on
            if countDownOn {
                display.setUICountdownOn()
                display.startCountDown()
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                    // begin to record a video
                    guard let self = self else {return}
                    self.beginRecording()
//                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                    let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
//                    try? FileManager.default.removeItem(at: outputURL)
//                    self.videoOutput.startRecording(to: outputURL, recordingDelegate: self)
//                    self.display.setUIRecording()
//                    self.startVideoTimer(with: self.display.currentVideoLength)
                }
            } else {
                beginRecording()
//                // begin to record a video
//                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
//                try? FileManager.default.removeItem(at: outputURL)
//                videoOutput.startRecording(to: outputURL, recordingDelegate: self)
//                display.setUIRecording()
//                startVideoTimer(with: display.currentVideoLength)
            }
        } else {
            // stop recording video
            videoOutput.stopRecording()
            display.setUIDefault()
        }
    }
    
    func beginRecording() {
        // begin to record a video
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: outputURL)
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        display.setUIRecording()
        startVideoTimer(with: display.currentVideoLength)
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func toggleCountDown() {
        countDownOn.toggle()
        display.toggleCountDownUI(isOn: countDownOn)
    }
    @objc func changeVideoLength() {
        display.changeVideoLength()
    }
    @objc func flipCamera() {
        //flip which camera is displaying
        switchCameraInput()
    }
    
    func startVideoTimer(with maxLength: videoLength) {
        // 20 second time limit on videos
        // TODO: add a display that shows how long recording is
        DispatchQueue.main.asyncAfter(deadline: .now() + maxLength.rawValue) { [weak self] in
            guard let self = self else {return}
            if self.videoOutput.isRecording {
                self.videoOutput.stopRecording()
                self.display.setUIDefault()
            }
        }
    }

}

// MARK: Camera recording output delegate
extension RecordClipViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error)
        } else {
            // if no error then show video on custom avplayer vc
            let player = AVPlayer(url: outputFileURL)
            let vc = RecordedClipPlayerViewController()
            vc.player = player
            vc.workoutID = workoutID
            vc.exerciseName = exerciseName
            vc.exercisePosition = exercisePosition
            vc.uploadingDelegate = self
            vc.addingDelegate = self.addingDelegate
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false, completion: nil)
        }
    }
}

extension RecordClipViewController: clipUploadingProtocol {
    func clipUploadedAndSaved() {
        self.dismiss(animated: true, completion: nil)
    }
}
