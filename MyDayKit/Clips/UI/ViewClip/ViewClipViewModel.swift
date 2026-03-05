//
//  ViewClipViewModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/03/2026.
//

import Foundation

class ViewClipViewModel {
    
    @Published var isLoading: Bool = false
    @Published var clip: Clip?
    
    let loader: ClipLoader
    let clipModel: MyDayClipModel
    let clipViewRecorder: ViewClipRecorder
    
    var dismissAction:(() -> ())?
    
    init(loader: ClipLoader, clipModel: MyDayClipModel, clipViewRecorder: ViewClipRecorder, dismissAction: (() -> ())? = nil) {
        self.loader = loader
        self.clipModel = clipModel
        self.clipViewRecorder = clipViewRecorder
        self.dismissAction = dismissAction
    }
    
    func loadClip() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let clip = try await loader.loadClip(with: clipModel.clipID)
                self.clip = clip
            } catch {
                print("load error -")
                print(String(describing: error))
            }
        }
    }
    
    /// Called once when the user closes the screen.
    func sendWatchAnalytics(
        watchedMoreThanThreeSeconds: Bool,
        watchedFullVideo: Bool,
        closePosition: Double,         // 0.0 – 1.0 fraction through the video
        loopCount: Int                 // number of times the video completed and looped
    ) {
        Task {
            do {
                clipViewRecorder.recordClipWatch(
                    clipID: clipModel.clipID,
                    watchedMoreThanThreeSeconds: watchedMoreThanThreeSeconds,
                    watchedFullVideo: watchedFullVideo,
                    closePosition: closePosition,
                    loopCount: loopCount
                )
                print("✅ Watch analytics sent — 3s:\(watchedMoreThanThreeSeconds) full:\(watchedFullVideo) pos:\(String(format:"%.2f", closePosition)) loops:\(loopCount)")
            } catch {
                print("❌ Watch analytics error: \(error)")
            }
        }
    }
}
