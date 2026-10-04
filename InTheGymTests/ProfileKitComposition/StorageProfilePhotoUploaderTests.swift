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

    /// Random pixels compress badly, the worst case for the size cap.
    private func noisyImage(side: Int) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { context in
            var generator = SystemRandomNumberGenerator()
            for y in stride(from: 0, to: side, by: 4) {
                for x in stride(from: 0, to: side, by: 4) {
                    UIColor(
                        red: .random(in: 0...1, using: &generator),
                        green: .random(in: 0...1, using: &generator),
                        blue: .random(in: 0...1, using: &generator),
                        alpha: 1
                    ).setFill()
                    context.fill(CGRect(x: x, y: y, width: 4, height: 4))
                }
            }
        }
    }
}
