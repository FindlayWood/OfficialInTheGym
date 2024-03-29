//
//  AVAsset+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension AVAsset {
    
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let avAssetImageGenerator = AVAssetImageGenerator(asset: self)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
//            let thumbnailTime = CMTimeMake(value: 1, timescale: 1) // redundant use - made a time 1 second in
            
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: .zero, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

extension URL {
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        
        let asset = AVAsset(url: self)
        
        DispatchQueue.global().async {
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
//            let thumbnailTime = CMTimeMake(value: 1, timescale: 1) // redundant use - made time 1 second in
            
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: .zero, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
