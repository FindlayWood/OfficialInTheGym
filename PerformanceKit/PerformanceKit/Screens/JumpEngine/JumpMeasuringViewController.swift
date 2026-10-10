//
//  JumpMeasuringViewController.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import AudioToolbox
import AVFoundation
import Combine
import UIKit

/// Records a jump with the camera, then hands the file on through
/// `onRecorded`. Moved from the app target as it was, with the legacy
/// `JumpCoordinatorFlow` replaced by that closure.
///
/// Dead code did not come across: a second `AVCaptureFileOutputRecordingDelegate`
/// conformance that was never the delegate (the view model is), its own unused
/// `beginRecording()` / `startVideoTimer()` / `setUpVideoOutput()`, and an
/// unused conformance to the app's `clipUploadingProtocol`.
class JumpMeasuringViewController: UIViewController {

    // MARK: - Properties
    var onRecorded: ((URL) -> Void)?
    var display = JumpMeasuringView()
    var viewModel = RecordJumpViewModel()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
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
        onRecorded?(outputFileURL)
    }

    @objc func recordButtonTapped() {
        if !viewModel.videoOutput.isRecording {
            if viewModel.countDownOn {
                playSound()
                display.setUICountdownOn()
                viewModel.startCountDown()
            } else {
                startRecording()
            }
        } else {
            AudioServicesPlaySystemSound(SystemSoundID(1118))
            viewModel.videoOutput.stopRecording()
            display.setUIDefault()
        }
    }

    @objc func dismissView() {
        viewModel.captureSession.stopRunning()
        dismiss(animated: true, completion: nil)
    }

    @objc func toggleCountDown() {
        viewModel.countDownOn.toggle()
        display.toggleCountDownUI(isOn: viewModel.countDownOn)
    }

    @objc func flipCamera() {
        switchCameraInput()
    }
}
