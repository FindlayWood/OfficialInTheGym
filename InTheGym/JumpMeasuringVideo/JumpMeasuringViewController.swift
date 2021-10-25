//
//  JumpMeasuringViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class JumpMeasuringViewController: UIViewController {
    
    var display = JumpMeasuringView()
    
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

    let videoPickerController = UIImagePickerController()
    
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
        display.recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    
    
    
    func setUpCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        setUpDevices()
        setUpVideoOutput()
        
    }

    func setUpDevices() {
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if device.hasMediaType(.video) {
                if device.position == .back {
                    backCamera = device
                } else if device.position == .front {
                    frontCamera = device
                }
            }
        }
        startSession()
    }
    
    func startSession() {
        guard let backInput = try? AVCaptureDeviceInput(device: backCamera),
              let frontInput = try? AVCaptureDeviceInput(device: frontCamera)
        else {return}
        frontCameraInput = frontInput
        backCameraInput = backInput
        
        captureSession.addInput(backCameraInput)
        
        configureDevice()
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        self.view.layer.insertSublayer(videoPreviewLayer, at: 0)
        videoPreviewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    func configureDevice() {
        if let device = backCamera {

            // 1
            for vFormat in backCamera!.formats {

                // 2
                let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                let frameRates = ranges[0]

                // 3
                if frameRates.maxFrameRate == 240 {

                    // 4
                    do {
                        try device.lockForConfiguration()
                        device.activeFormat = vFormat
                        device.activeVideoMinFrameDuration = frameRates.minFrameDuration
                        device.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                        device.unlockForConfiguration()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else if let device = frontCamera {
            // 1
            for vFormat in backCamera!.formats {

                // 2
                let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                let frameRates = ranges[0]

                // 3
                if frameRates.maxFrameRate == 60 {

                    do {
                        try device.lockForConfiguration()
                        device.activeFormat = vFormat
                        device.activeVideoMinFrameDuration = frameRates.minFrameDuration
                        device.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                        device.unlockForConfiguration()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }

        }
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
                }
            } else {
                beginRecording()
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
        startVideoTimer()
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func toggleCountDown() {
        countDownOn.toggle()
        display.toggleCountDownUI(isOn: countDownOn)
    }
    @objc func flipCamera() {
        //flip which camera is displaying
        switchCameraInput()
    }
    
    func startVideoTimer() {
        // 30 second time limit on videos
        // TODO: add a display that shows how long recording is
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self else {return}
            if self.videoOutput.isRecording {
                self.videoOutput.stopRecording()
                self.display.setUIDefault()
            }
        }
    }
}

// MARK: Camera recording output delegate
extension JumpMeasuringViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error)
        } else {
            readerGetFrames(from: outputFileURL)
        }
    }
    func convertToSlowMotion(from videoURL: URL, completion: @escaping (AVAssetExportSession?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let currentTrack = asset.tracks(withMediaType: .video)[0]
        let mixCompostion = AVMutableComposition()
        let compositionVideoTrack = mixCompostion.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: currentTrack, at: .zero)
        } catch {
            print(error.localizedDescription)
        }
        
        compositionVideoTrack?.scaleTimeRange(CMTimeRange(start: .zero, duration: asset.duration),
                                              toDuration: CMTime(value: asset.duration.value * Int64(2), timescale: asset.duration.timescale))
        compositionVideoTrack?.preferredTransform = currentTrack.preferredTransform
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: outputURL)
        
        let assetExport = AVAssetExportSession(asset: mixCompostion, presetName: AVAssetExportPresetHighestQuality)
        assetExport?.outputURL = outputURL
        assetExport?.outputFileType = .mp4
        assetExport?.exportAsynchronously {
            completion(assetExport)
        }
    }
    
    func readerGetFrames(from videoURL: URL) {
        let asset = AVAsset(url: videoURL)
        guard let assetReader = try? AVAssetReader(asset: asset) else {return}
        guard let videoTracks = asset.tracks(withMediaType: .video).first else {return}
        
        let outputSettings = [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)]
        let trackReaderOutput = AVAssetReaderTrackOutput(track: videoTracks,
                                                                     outputSettings: outputSettings)
        
        assetReader.add(trackReaderOutput)
        assetReader.startReading()
        
        var frames: [UIImage] = [UIImage]()
        var timeStamps: [Double] = [Double]()
        
        while let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let attachments = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: imageBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
                let ciImage = CIImage(cvImageBuffer: imageBuffer, options: attachments as? [CIImageOption : Any])
                let image = UIImage(ciImage: ciImage.oriented(.right))
                let frameTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                timeStamps.append(Double(CMTimeGetSeconds(frameTimeStamp)))
                frames.append(image)
            }
        }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: outputURL)
        
        
        let vc = ReplayJumpMeasureViewController()
        vc.frames = frames
        vc.timeStamps = timeStamps
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
}

extension JumpMeasuringViewController: clipUploadingProtocol {
    func clipUploadedAndSaved() {
        self.dismiss(animated: true, completion: nil)
    }
}

