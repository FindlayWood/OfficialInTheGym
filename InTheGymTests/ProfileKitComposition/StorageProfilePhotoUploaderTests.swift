//
//  StorageProfilePhotoUploaderTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import UIKit
import XCTest
@testable import InTheGym

final class StorageProfilePhotoUploaderTests: XCTestCase {

    // FirebaseStorageManager.downloadImage refuses anything over 720 x 720
    // bytes. A photo encoded larger would upload and then never load anywhere.
    func test_encode_fitsADetailedPhotoUnderTheDownloadCap() throws {
        let sut = try XCTUnwrap(StorageProfilePhotoUploader.encode(noisyImage(side: 2400)))

        XCTAssertLessThanOrEqual(sut.count, StorageProfilePhotoUploader.maxBytes)
        let decoded = try XCTUnwrap(UIImage(data: sut))
        XCTAssertLessThanOrEqual(max(decoded.size.width, decoded.size.height), StorageProfilePhotoUploader.maxDimension)
    }

    func test_encode_doesNotUpscaleASmallPhoto() throws {
        let sut = try XCTUnwrap(StorageProfilePhotoUploader.encode(noisyImage(side: 300)))

        XCTAssertEqual(try XCTUnwrap(UIImage(data: sut)).size.width, 300, accuracy: 1)
    }

    // MARK: - Helpers

    /// Random 4x4 blocks compress badly, the worst case for the size cap.
    ///
    /// **The bytes are written straight into a bitmap.** This used to fill each
    /// block through `UIGraphicsImageRenderer` — 360,000 `UIColor`s and `fill`
    /// calls for a 2400 image — which took over seventeen minutes on the
    /// simulator and ran the CI job out of time on its own.
    private func noisyImage(side: Int) -> UIImage {
        let bytesPerRow = side * 4
        var pixels = [UInt8](repeating: 255, count: bytesPerRow * side)
        var generator = SystemRandomNumberGenerator()
        for blockY in stride(from: 0, to: side, by: 4) {
            for blockX in stride(from: 0, to: side, by: 4) {
                let colour = (0..<3).map { _ in UInt8.random(in: 0...255, using: &generator) }
                for y in blockY..<min(blockY + 4, side) {
                    for x in blockX..<min(blockX + 4, side) {
                        let offset = y * bytesPerRow + x * 4
                        pixels[offset] = colour[0]
                        pixels[offset + 1] = colour[1]
                        pixels[offset + 2] = colour[2]
                    }
                }
            }
        }
        let image = pixels.withUnsafeMutableBytes { buffer in
            CGContext(
                data: buffer.baseAddress,
                width: side,
                height: side,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )?.makeImage()
        }
        return UIImage(cgImage: image!)
    }
}
