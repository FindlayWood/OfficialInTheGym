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

protocol clipUploadingProtocol: AnyObject {
    func clipUploadedAndSaved()
}
protocol addedClipProtocol: AnyObject {
    func clipAdded(with data: clipSuccessData)
}

class RecordedClipPlayerViewController: UIViewController {
    
    var player: AVPlayer!
    
    var display = RecordedClipView()
    
    var paused: Bool = false
    
    var workoutID: String!
    var clipNumber: Int!
    var exerciseName: String!
    
    weak var uploadingDelegate: clipUploadingProtocol!
    weak var addingDelegate: addedClipProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        addObservers()
        addButtonActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
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
            paused.toggle()
        } else {
            player.pause()
            paused.toggle()
        }
    }
    
    @objc func removeFromFileManager() {
        dismiss(animated: true, completion: nil)
        guard let currentVideoURL = ((player.currentItem?.asset) as? AVURLAsset)?.url else {return}
        try? FileManager.default.removeItem(at: currentVideoURL)
    }
    
    //TODO: Save video to firebase
    @objc func saveVideoToFirebase() {
        player.pause()
        display.attemptingToSaveClip()
        guard let currentVideoURL = ((player.currentItem?.asset) as? AVURLAsset)?.url else {return}
        player.currentItem?.asset.generateThumbnail(completion: { [weak self] thumbnail in
            guard let self = self else {return}
            let clipUploadData = clipUploadingData(workoutID: self.workoutID,
                                                   exerciseName: self.exerciseName,
                                                   clipNumber: self.clipNumber,
                                                   videoURL: currentVideoURL,
                                                   isPrivate: self.display.isPrivate,
                                                   thumbnail: thumbnail)
            
            FirebaseVideoUploader.shared.upload(uploadData: clipUploadData) { [weak self] result in
                guard let self = self else {return}
                switch result {
                case .failure(let uploadError):
                    print(uploadError.localizedDescription)
                    self.showUploadError()
                    self.display.setToRecord()
                case .success(let addingData):
                    self.dismiss(animated: true, completion: nil)
                    self.removeFromFileManager()
                    self.uploadingDelegate.clipUploadedAndSaved()
                    self.addingDelegate.clipAdded(with: addingData)
                }
            } progressCompletion: { [weak self] progress in
                guard let self = self else {return}
                self.display.updateProgressBar(to: progress)
            }
            
            
        })
//        let clipUploadData = clipUploadingData(workoutID: workoutID,
//                                               exerciseName: exerciseName,
//                                               clipNumber: clipNumber,
//                                               videoURL: currentVideoURL,
//                                               isPrivate: display.isPrivate)
//        
//        FirebaseVideoUploader.shared.upload(uploadData: clipUploadData) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .failure(let uploadError):
//                print(uploadError.localizedDescription)
//                self.showUploadError()
//                self.display.setToRecord()
//            case .success(let addingData):
//                self.dismiss(animated: true, completion: nil)
//                self.removeFromFileManager()
//                self.uploadingDelegate.clipUploadedAndSaved()
//                self.addingDelegate.clipAdded(with: addingData)
//            }
//        } progressCompletion: { [weak self] progress in
//            guard let self = self else {return}
//            self.display.updateProgressBar(to: progress)
//        }
    }
    
    func showUploadError() {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "There was an error uploading this clip, please try again.", closeButtonTitle: "ok")
    }
    
    @objc func togglePrivacy() {
        display.togglePrivacy()
    }
}
