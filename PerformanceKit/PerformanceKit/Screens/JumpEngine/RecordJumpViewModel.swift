//
//  RecordJumpViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
import Combine
import AVFoundation

/// The camera behind the jump recorder: a capture session with both cameras,
/// 240fps on the back camera where the device offers it, an optional ten-second
/// countdown, and a sixteen-second cap on the recording. Moved from the app
/// target as it was.
class RecordJumpViewModel: NSObject {
    // MARK: - Publishers
    var outPutFilePublisher = PassthroughSubject<URL,Never>()
    @Published var countDownTime: Int = 10
    // MARK: - Properties
    var countDownTimer: AnyCancellable!
    var recordingTimer: AnyCancellable!
    
    var captureSession: AVCaptureSession!
    var backCamera: AVCaptureDevice!
    var frontCamera: AVCaptureDevice!
    var backCameraInput: AVCaptureInput!
    var frontCameraInput: AVCaptureInput!
    var videoOutput: AVCaptureMovieFileOutput!
    var backCameraOn: Bool = true
    var countDownOn: Bool = false
    // MARK: - Actions
    func beginRecording() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: outputURL)
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    // MARK: - Functions
    func setUpCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        setUpDevices()
        setUpVideoOutput()
    }

    func setUpDevices() {
        let c = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)

        for device in c.devices {
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
    
    /// The router only opens the recorder once `JumpCameraAvailability` says
    /// both cameras exist and access is granted. These guards are the second
    /// line: a missing camera leaves the session without inputs rather than
    /// force-unwrapping nil, which is how it used to crash.
    func startSession() {
        guard let backCamera, let frontCamera,
              let backInput = try? AVCaptureDeviceInput(device: backCamera),
              let frontInput = try? AVCaptureDeviceInput(device: frontCamera)
        else { return }
        frontCameraInput = frontInput
        backCameraInput = backInput
        captureSession.addInput(backCameraInput)
        configureDevice()
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
    
    func setUpVideoOutput() {
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }
    // MARK: - Start Recording Timer
    /// 16 second max recording length
    func startRecordingTimer() {
        recordingTimer = Timer.publish(every: 16, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.videoOutput.stopRecording()
            }
    }
    // MARK: - Start Countdown Timer
    /// 10 second countdown timer
    func startCountDown() {
        countDownTime = 10
        countDownTimer = Timer.publish(every: 1.0, on: RunLoop.main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.changeCountDown()}
    }
    func changeCountDown() {
        countDownTime -= 1
    }
}
// MARK: - Camera recording output delegate
extension RecordJumpViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        recordingTimer.cancel()
        if let error = error {
            print(error)
        } else {
            outPutFilePublisher.send(outputFileURL)
        }
    }
}
