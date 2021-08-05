//
//  ThumbnailGenerator.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import AVKit

class ThumbnailGenerator {
    
    static var shared = ThumbnailGenerator()
    
    private init () {}
    
    let thumbnailCache = NSCache<NSString,UIImage>()
    
    func getImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let image = self.thumbnailCache.object(forKey: urlString as NSString) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    guard let url = URL(string: urlString) else {return}
                    self.generateThumbnail(from: url, completion: completion)
                }
            }
        }
    }
    
    private func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 1, timescale: 1)
            
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                    self.thumbnailCache.setObject(thumbImage, forKey: url.absoluteString as NSString)
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
