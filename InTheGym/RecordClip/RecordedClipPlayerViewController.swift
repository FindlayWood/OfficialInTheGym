//
//  RecordedClipPlayerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SCLAlertView
import Combine



class RecordedClipPlayerViewController: UIViewController {
    
    // MARK: - Properties
    var player: AVPlayer!
    
    var display = RecordedClipView()
    
    var paused: Bool = false
    
    var workoutID: String!
    var clipNumber: Int!
    var exerciseName: String!
    
    weak var uploadingDelegate: clipUploadingProtocol!
    weak var addingDelegate: addedClipProtocol!
    
    var viewModel = RecordedClipPlayerViewModel()

    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        addObservers()
        addButtonActions()
        setupSubscriptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player = AVPlayer(url: viewModel.clipStorageModel.fileURL)
        let layer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(layer)
        player.play()
        
        guard let currentVideoLength = ((player.currentItem?.asset) as? AVURLAsset)?.duration.seconds else {return}
        print(currentVideoLength)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }
    
    func addButtonActions() {
        display.backButton.addTarget(self, action: #selector(removeFromFileManager), for: .touchUpInside)
        display.saveButton.addTarget(self, action: #selector(saveVideoToFirebase), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePause))
        display.addGestureRecognizer(tap)
        display.privacyButton.addTarget(self, action: #selector(togglePrivacy), for: .touchUpInside)
    }
 
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(restartVideo), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func restartVideo() {
        player.seek(to: .zero)
        player.play()
    }
    
    @objc func togglePause() {
        if paused {
            player.play()
            viewModel.paused = false
            paused.toggle()
        } else {
            player.pause()
            viewModel.paused = true
            paused.toggle()
        }
    }
    
    func setupSubscriptions() {
        viewModel.thumbnailGenerated
            .sink { [weak self] thumbnail in
                let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
                view.image = thumbnail
                self?.view.addSubview(view)
            }
            .store(in: &subscriptions)
    }
    
    @objc func removeFromFileManager() {
        viewModel.removeFromFileManager()
        dismiss(animated: true, completion: nil)
    }
    
    //TODO: Save video to firebase
    @objc func saveVideoToFirebase() {
        player.pause()
        display.attemptingToSaveClip()
        viewModel.uploadClipToStorage()
    }
    
    func showUploadError() {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "There was an error uploading this clip, please try again.", closeButtonTitle: "ok")
    }
    
    @objc func togglePrivacy() {
        display.togglePrivacy()
    }
}
