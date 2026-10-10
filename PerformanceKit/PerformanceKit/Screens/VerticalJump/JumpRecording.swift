//
//  JumpRecording.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import UIKit

/// The jump camera and the frame-by-frame replay, for the app target's CMJ
/// tool, which records its jumps the same way Vertical Jump does.
///
/// **This is the only copy of either screen, and of the height formula in
/// `JumpMeasureViewModel`.** CMJ is commented out of Performance Center and
/// stays in the app target until someone decides whether it returns, so rather
/// than leave a second copy of both screens behind for it, CMJ builds them from
/// here. Two copies of a formula is the defect *A rule that exists in two
/// places* describes. Only this factory is public, so the screens' internals
/// are not.
public enum JumpRecording {

    /// The camera. `onRecorded` receives the recorded file.
    @MainActor
    public static func makeRecorder(onRecorded: @escaping (URL) -> Void) -> UIViewController {
        let vc = JumpMeasuringViewController()
        vc.onRecorded = onRecorded
        return vc
    }

    /// The replay of `fileURL`. `onHeightCalculated` receives the height in
    /// centimetres once take-off and landing are tagged.
    @MainActor
    public static func makeReplay(fileURL: URL, onHeightCalculated: @escaping (Double) -> Void) -> UIViewController {
        let vc = ReplayJumpMeasureViewController()
        vc.viewModel.fileURL = fileURL
        vc.onHeightCalculated = onHeightCalculated
        return vc
    }
}
