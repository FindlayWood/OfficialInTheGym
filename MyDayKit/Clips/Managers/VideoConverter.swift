//
//  VideoConverter.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/02/2026.
//

import AVFoundation
import Foundation

public class VideoConverter {
    let userID: String
    let thumbnailGenerator: VideoThumbnailGenerating
    
    public init(userID: String, thumbnailGenerator: VideoThumbnailGenerating) {
        self.userID = userID
        self.thumbnailGenerator = thumbnailGenerator
    }
    
    private func loadVideoData(from url: URL) throws -> Data {
        return try Data(contentsOf: url, options: .mappedIfSafe)
    }
    
    private func extractVideoMetadata(from url: URL, fileSize: Int64) async throws -> ClipUploadData.VideoMetadata {
        let asset = AVURLAsset(url: url)

        let durationTime = try await asset.load(.duration)
        let duration = CMTimeGetSeconds(durationTime)

        let track = try? await asset.loadTracks(withMediaType: .video).first
        let size = try? await track?.load(.naturalSize)
        let transform = try? await track?.load(.preferredTransform)

        let transformedSize = size?.applying(transform ?? .identity)

        let width = abs(Int(transformedSize?.width ?? 0))
        let height = abs(Int(transformedSize?.height ?? 0))

        // ⬅️ dynamic codec
        let formatDescriptions = track?.formatDescriptions as? [CMFormatDescription]
        let codec = formatDescriptions
            .flatMap { $0.first }
            .map { FourCharCodeToString(CMFormatDescriptionGetMediaSubType($0)) }
            ?? "unknown"

        return .init(
            contentType: mimeType(for: url),
            duration: duration,
            width: width,
            height: height,
            fileSize: fileSize,
            codec: codec
        )
    }
    
    private func FourCharCodeToString(_ code: FourCharCode) -> String {
        let bytes: [CChar] = [
            CChar((code >> 24) & 0xff),
            CChar((code >> 16) & 0xff),
            CChar((code >>  8) & 0xff),
            CChar(code         & 0xff),
            0
        ]
        return String(cString: bytes)
    }

    func mimeType(for url: URL) -> String {
        let ext = url.pathExtension
        if let type = UTType(filenameExtension: ext),
           let mime = type.preferredMIMEType {
            return mime
        }
        return "application/octet-stream"
    }
    

    func buildClipUploadData(from url: URL, exerciseID: String, isPrivate: Bool) async throws -> ClipUploadData {

        let videoData = try loadVideoData(from: url)
        
        let thumbnail = await thumbnailGenerator.generateThumbnail(from: url, maxSize: 300, compressionQuality: 0.7)
        
        // Convert thumbnail to Data
        let thumbnailData = thumbnail?.jpegData(compressionQuality: 0.7)
        
        let fileSize = Int64(videoData.count)

        let metadata = try await extractVideoMetadata(
            from: url,
            fileSize: fileSize
        )

        return ClipUploadData(
            videoData: videoData,
            thumbnailData: thumbnailData,
            userID: userID,
            clipID: UUID().uuidString,
            exerciseID: exerciseID,
            isPrivate: isPrivate,
            videoMetadata: metadata
        )
    }
}
