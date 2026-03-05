//
//  UploadProgressView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 24/01/2026.
//

import SwiftUI

// MARK: - Upload Progress State
enum UploadProgressState: Equatable {
    case idle
    case uploading(progress: Double)
    case success(result: ClipUploadResult)
    case failed(message: String)
    case cancelled
    
    var isActive: Bool {
        switch self {
        case .uploading:
            return true
        default:
            return false
        }
    }
}

// MARK: - Upload Progress View
struct UploadProgressView: View {
    
    var state: UploadProgressState
    let canCancel: Bool
    
    let onComplete: (ClipUploadResult) -> Void
    let cancelUpload: () -> Void
    let onDismiss: () -> Void
    
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Progress card
            VStack(spacing: 20) {
                stateContent
                    .frame(maxWidth: .infinity)
                
                actionButtons
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 32)
        }
    }
    
    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .idle:
            EmptyView()
            
        case .uploading(let progress):
            uploadingContent(progress: progress)
            
        case .success(let result):
            successContent(result: result)
            
        case .failed(let message):
            failedContent(message: message)
            
        case .cancelled:
            cancelledContent
        }
    }
    
    private func uploadingContent(progress: Double) -> some View {
        VStack(spacing: 16) {
            // Circular progress indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text("Uploading Clip")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Please don't close the app")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private func successContent(result: ClipUploadResult) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(showCheckmark ? 1.0 : 0.5)
                    .opacity(showCheckmark ? 1.0 : 0.0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showCheckmark = true
                }
                
                // Auto-dismiss after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onComplete(result)
                }
            }
            
            Text("Upload Complete!")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Your clip has been saved")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private func failedContent(message: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "xmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Upload Failed")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var cancelledContent: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "stop.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Upload Cancelled")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Your clip was not saved")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        switch state {
        case .uploading:
            if canCancel {
                Button(action: cancelUpload) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
            
        case .failed, .cancelled:
            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                
                Button(action: {
                    // Retry logic would be handled by parent
                    onDismiss()
                }) {
                    Text("Retry")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                }
            }
            
        default:
            EmptyView()
        }
    }
}
