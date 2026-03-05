//
//  ThumbnailGenerator.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/02/2026.
//

import AVFoundation
import UIKit

// MARK: - Protocol

/// Protocol for generating video thumbnails - useful for dependency injection and testing
public protocol VideoThumbnailGenerating {
    /// Generates a thumbnail from a video URL
    /// - Parameters:
    ///   - videoURL: The URL of the video file
    ///   - maxSize: Maximum dimension (width or height) for the thumbnail
    ///   - compressionQuality: JPEG compression quality (0.0 to 1.0)
    /// - Returns: A compressed UIImage of the first frame, or nil if generation fails
    func generateThumbnail(
        from videoURL: URL,
        maxSize: CGFloat,
        compressionQuality: CGFloat
    ) async -> UIImage?
}

// MARK: - Implementation

/// Generates a compressed thumbnail image from the first frame of a video
public class VideoThumbnailGenerator: VideoThumbnailGenerating {
    
    public init() {}
    
    /// Generates a thumbnail from a video URL
    /// - Parameters:
    ///   - videoURL: The URL of the video file
    ///   - maxSize: Maximum dimension (width or height) for the thumbnail. Default is 400.
    ///   - compressionQuality: JPEG compression quality (0.0 to 1.0). Default is 0.7.
    /// - Returns: A compressed UIImage of the first frame, or nil if generation fails
    public func generateThumbnail(
        from videoURL: URL,
        maxSize: CGFloat = 400,
        compressionQuality: CGFloat = 0.7
    ) async -> UIImage? {
        
        let asset = AVURLAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        // Improve thumbnail quality
        imageGenerator.appliesPreferredTrackTransform = true // Handle video rotation
        imageGenerator.requestedTimeToleranceBefore = .zero  // Get exact first frame
        imageGenerator.requestedTimeToleranceAfter = .zero
        
        do {
            // Generate image at time 0 (first frame) - iOS 18+ API
            if #available(iOS 16.0, *) {
                let (cgImage, _) = try await imageGenerator.image(at: .zero)
                var thumbnail = UIImage(cgImage: cgImage)
                
                // Resize if needed
                thumbnail = resizeImage(thumbnail, maxSize: maxSize)
                
                // Compress the image
                if let compressedData = thumbnail.jpegData(compressionQuality: compressionQuality),
                   let compressedImage = UIImage(data: compressedData) {
                    return compressedImage
                }
                
                return thumbnail
            } else {
                // Fallback for older iOS versions
                let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                var thumbnail = UIImage(cgImage: cgImage)
                
                // Resize if needed
                thumbnail = resizeImage(thumbnail, maxSize: maxSize)
                
                // Compress the image
                if let compressedData = thumbnail.jpegData(compressionQuality: compressionQuality),
                   let compressedImage = UIImage(data: compressedData) {
                    return compressedImage
                }
                
                return thumbnail
            }
            
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Resizes an image to fit within a maximum dimension while maintaining aspect ratio
    /// - Parameters:
    ///   - image: The image to resize
    ///   - maxSize: Maximum width or height
    /// - Returns: Resized UIImage
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        
        // If image is already smaller, return as-is
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let widthRatio = maxSize / size.width
        let heightRatio = maxSize / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        // Render the resized image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
}

// MARK: - Mock for Testing

/// Mock implementation for unit testing
class MockThumbnailGenerator: VideoThumbnailGenerating {
    var shouldReturnNil = false
    var mockImage: UIImage?
    var capturedVideoURL: URL?
    var capturedMaxSize: CGFloat?
    var capturedCompressionQuality: CGFloat?
    
    func generateThumbnail(
        from videoURL: URL,
        maxSize: CGFloat,
        compressionQuality: CGFloat
    ) async -> UIImage? {
        // Capture parameters for testing assertions
        capturedVideoURL = videoURL
        capturedMaxSize = maxSize
        capturedCompressionQuality = compressionQuality
        
        if shouldReturnNil {
            return nil
        }
        
        // Return mock image or create a simple one
        return mockImage ?? createMockImage()
    }
    
    private func createMockImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
