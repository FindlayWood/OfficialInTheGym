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
import Combine
import AudioToolbox

class JumpMeasuringViewController: UIViewController {
    // MARK: - Properties
    var display = JumpMeasuringView()
    var viewModel = RecordJumpViewModel()
    
//    var captureSession: AVCaptureSession!
//    
//    var backCamera: AVCaptureDevice!
//    var frontCamera: AVCaptureDevice!
//    
//    var audio: AVCaptureDevice!
//    
//    var backCameraInput: AVCaptureInput!
//    var frontCameraInput: AVCaptureInput!
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
//    var videoOutput: AVCaptureMovieFileOutput!
//
//    var backCameraOn: Bool = true
//
//    var countDownOn: Bool = false

    let videoPickerController = UIImagePickerController()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.setUpCaptureSession()
        setupVideoPreviewLayer()
        displaySetUp()
        switchCameraInput()
        switchCameraInput()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func displaySetUp() {
        display.backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        display.flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        display.countDownButton.addTarget(self, action: #selector(toggleCountDown), for: .touchUpInside)
        display.recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    func setupVideoPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        videoPreviewLayer?.frame = view.bounds
        viewModel.captureSession.startRunning()
    }
    
    func initViewModel() {
        // MARK: - Subscriptions
        viewModel.outPutFilePublisher
            .sink { [weak self] in self?.finishedRecording(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.$countDownTime
            .dropFirst()
            .sink { [weak self] newTime in
                if newTime > 0 {
                    self?.display.setCountDown(to: newTime)
                    if newTime < 4 {
                        self?.playSound()
                    }
                } else {
                    self?.display.setUIRecording()
                    self?.viewModel.countDownTimer.cancel()
                    self?.startRecording()
                }
            }
            .store(in: &subscriptions)
    }
    
    func switchCameraInput() {
        display.flipCameraButton.isUserInteractionEnabled = false
        viewModel.captureSession.beginConfiguration()
        if viewModel.backCameraOn {
            viewModel.captureSession.removeInput(viewModel.backCameraInput)
            viewModel.captureSession.addInput(viewModel.frontCameraInput)
            viewModel.backCameraOn = false
        } else {
            viewModel.captureSession.removeInput(viewModel.frontCameraInput)
            viewModel.captureSession.addInput(viewModel.backCameraInput)
            viewModel.backCameraOn = true
        }
        
        videoPreviewLayer.connection?.videoOrientation = .portrait
        viewModel.captureSession.commitConfiguration()
        display.flipCameraButton.isUserInteractionEnabled = true
    }
    
    func setUpVideoOutput() {
        viewModel.videoOutput = AVCaptureMovieFileOutput()
        if viewModel.captureSession.canAddOutput(viewModel.videoOutput) {
            viewModel.captureSession.addOutput(viewModel.videoOutput)
        }
    }
    func playSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1117))
    }
    func startRecording() {
        viewModel.beginRecording()
        viewModel.startRecordingTimer()
        display.setUIRecording()
    }
    func finishedRecording(with outputFileURL: URL) {
        AudioServicesPlaySystemSound(SystemSoundID(1118))
        display.setUIDefault()
        let asset = AVAsset(url: outputFileURL)
        print(asset.tracks(withMediaType: .video).first?.nominalFrameRate)
        let vc = ReplayJumpMeasureViewController()
        vc.viewModel.fileURL = outputFileURL
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .coverVertical
        present(nav, animated: false, completion: nil)
    }
    @objc func recordButtonTapped() {
        if !viewModel.videoOutput.isRecording {
            //check if countdown is on
            if viewModel.countDownOn {
                playSound()
                display.setUICountdownOn()
                viewModel.startCountDown()
            } else {
                startRecording()
            }
        } else {
            // stop recording video
            AudioServicesPlaySystemSound(SystemSoundID(1118))
            viewModel.videoOutput.stopRecording()
            display.setUIDefault()
        }
        
        
//        if !videoOutput.isRecording {
//            //check if countdown is on
//            if countDownOn {
//                display.setUICountdownOn()
//                display.startCountDown()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
//                    // begin to record a video
//                    guard let self = self else {return}
//                    self.beginRecording()
//                }
//            } else {
//                beginRecording()
//            }
//        } else {
//            // stop recording video
//            videoOutput.stopRecording()
//            display.setUIDefault()
//        }
    }
    
    func beginRecording() {
        // begin to record a video
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let outputURL = path[0].appendingPathComponent("output").appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: outputURL)
        viewModel.videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        display.setUIRecording()
        startVideoTimer()
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func toggleCountDown() {
        viewModel.countDownOn.toggle()
        display.toggleCountDownUI(isOn: viewModel.countDownOn)
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
            if self.viewModel.videoOutput.isRecording {
                self.viewModel.videoOutput.stopRecording()
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
            let asset = AVAsset(url: outputFileURL)
            print(asset.tracks(withMediaType: .video).first?.nominalFrameRate)
            let vc = ReplayJumpMeasureViewController()
            vc.viewModel.fileURL = outputFileURL
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .fullScreen
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.modalTransitionStyle = .coverVertical
            present(nav, animated: false, completion: nil)
        }
    }
}

extension JumpMeasuringViewController: clipUploadingProtocol {
    func clipUploadedAndSaved() {
        self.dismiss(animated: true, completion: nil)
    }
}

