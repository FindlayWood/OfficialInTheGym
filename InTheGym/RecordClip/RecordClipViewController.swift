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
import Combine

class RecordClipViewController: UIViewController {
    
    // MARK: - Properties
    var display = RecordClipView()
    
    weak var coordinator: ClipCoordinator?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var addingDelegate: addedClipProtocol!
    
    var viewModel = RecordClipViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        viewModel.setUpCaptureSession()
        setUpPreviewLayer()
        
        displaySetUp()
        
        setupSubscriptions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    func setUpPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoPreviewLayer.frame = self.view.frame
        self.view.layer.insertSublayer(videoPreviewLayer, at: 0)
    }

    
    // MARK: - Button Actions
    func displaySetUp() {
        display.backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        display.flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        display.countDownButton.addTarget(self, action: #selector(toggleCountDown), for: .touchUpInside)
        display.recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Subscriptions
    func setupSubscriptions() {
        viewModel.outPutFilePublisher
            .sink { [weak self] in self?.finishedRecording(with: $0) }
            .store(in: &subscriptions)
    }
    
    func finishedRecording(with outputFileURL: URL) {
        let clipStorageModel = ClipStorageModel(fileURL: outputFileURL)
//        coordinator?.finishedRecording(clipStorageModel)
        
        let vc = RecordedClipPlayerViewController()
        vc.viewModel.exerciseModel = viewModel.exerciseModel
        vc.viewModel.workoutModel = viewModel.workoutModel
        vc.viewModel.clipStorageModel = clipStorageModel
        vc.viewModel.addDelegate = viewModel.addingDelegate
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
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
    
    @objc func recordButtonTapped() {
        if !viewModel.videoOutput.isRecording {
            //check if countdown is on
            if viewModel.countDownOn {
                display.setUICountdownOn()
                display.startCountDown()
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                    // begin to record a video
                    guard let self = self else {return}
                    self.beginRecording()
                    self.viewModel.beginRecording()
                }
            } else {
                beginRecording()
                viewModel.beginRecording()
//                // begin to record a video
            }
        } else {
            // stop recording video
            viewModel.videoOutput.stopRecording()
            display.setUIDefault()
        }
    }
    
    func beginRecording() {
        display.setUIRecording()
        startVideoTimer()
    }
    
    func startVideoTimer() {
        // TODO: add a display that shows how long recording is
        DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.maxVideoLength) { [weak self] in
            guard let self = self else {return}
            if self.viewModel.videoOutput.isRecording {
                self.viewModel.videoOutput.stopRecording()
                self.display.setUIDefault()
            }
        }
    }
}

// MARK: - Actions
private extension RecordClipViewController {

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
}

// MARK: - Camera recording output delegate

extension RecordClipViewController: clipUploadingProtocol {
    func clipUploadedAndSaved() {
        self.dismiss(animated: true, completion: nil)
    }
}
