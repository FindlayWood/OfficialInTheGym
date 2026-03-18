//
//  UploadManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 26/01/2026.
//

import Combine
import Foundation

public class UploadManager: ObservableObject {
    @Published private(set) var state: UploadProgressState = .idle
    @Published private(set) var canCancel: Bool = true
    @Published private(set) var isUploading: Bool = false
    
    private var uploadTask: Task<Void, Never>?
    
    let clipUploader: ClipUploader
    
    public init(clipUploader: ClipUploader) {
        self.clipUploader = clipUploader
    }
    
    func updateProgress(_ progress: Double) {
        DispatchQueue.main.async {
            self.state = .uploading(progress: progress)
        }
    }
    
    func markSuccess(_ result: ClipUploadResult) {
        DispatchQueue.main.async {
            self.state = .success(result: result)
            self.canCancel = false
        }
    }
    
    func markFailed(_ message: String) {
        DispatchQueue.main.async {
            self.state = .failed(message: message)
            self.canCancel = false
        }
    }
    
    func markCancelled() {
        DispatchQueue.main.async {
            self.state = .cancelled
            self.canCancel = false
        }
    }
    
    func cancelUpload() {
        guard canCancel else { return }
        uploadTask?.cancel()
        markCancelled()
    }
    
    func setUploading(_ isUploading: Bool) {
        DispatchQueue.main.async {
            self.isUploading = isUploading
        }
    }
    
    func startUpload(uploadData: ClipUploadData) {
        self.setUploading(true)
        // Cancel any existing upload
        uploadTask?.cancel()
        
        uploadTask = Task {
            do {
                // Upload with progress tracking
                let result = try await clipUploader.uploadClip(uploadData) { progress in
                    self.updateProgress(progress)
                }
                
                // Success
                self.markSuccess(result)
                print("Upload complete: \(result.videoURL)")
                self.setUploading(false)
                
            } catch is CancellationError {
                self.markCancelled()
                self.setUploading(false)
            } catch {
                self.markFailed(error.localizedDescription)
                self.setUploading(false)
            }
        }
    }
}
