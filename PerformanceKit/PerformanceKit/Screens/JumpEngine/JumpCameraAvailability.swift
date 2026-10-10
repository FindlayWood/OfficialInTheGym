//
//  JumpCameraAvailability.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import AVFoundation

/// Whether the jump camera can run, checked **before** the recorder is shown.
///
/// The recorder assumed a back and a front camera and permission to use them.
/// With no camera (the simulator) or with access denied, the inputs it builds
/// are nil, and it crashed force-unwrapping them the moment it opened. Now the
/// router asks this first and shows `JumpCameraUnavailableScreen` instead.
enum JumpCameraAvailability: Equatable {
    case available
    case denied
    case noCamera

    /// The current state, asking for access first if it has never been asked.
    static func check() async -> JumpCameraAvailability {
        guard hasBothCameras else { return .noCamera }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .available
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video) ? .available : .denied
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }

    /// The recorder records on the back camera and can flip to the front, so
    /// it needs both. Every iPhone has both; the simulator has neither.
    private static var hasBothCameras: Bool {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        return devices.contains { $0.position == .back } && devices.contains { $0.position == .front }
    }
}
