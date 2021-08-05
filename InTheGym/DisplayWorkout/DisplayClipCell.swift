//
//  DisplayClipCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class DisplayClipCell: UICollectionViewCell {
    
    var thumbnailImage: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUpView() {
        backgroundColor = .lightGray
        layer.cornerRadius = 40
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        layer.masksToBounds = true
        addSubview(thumbnailImage)
        constrainView()
    }
    
    private func constrainView() {
        NSLayoutConstraint.activate([thumbnailImage.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     thumbnailImage.topAnchor.constraint(equalTo: topAnchor),
                                     thumbnailImage.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     thumbnailImage.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    func attachThumbnail(from urlString: String) {
        if #available(iOS 13.0, *) {
            thumbnailImage.image = UIImage(systemName: "play.fill")
            thumbnailImage.tintColor = Constants.darkColour
        }
//        ThumbnailGenerator.shared.getImage(from: urlString) { [weak self] thumbnail in
//            guard let self = self else {return}
//            if let image = thumbnail {
//                self.thumbnailImage.image = image
//            }
//        }
    }
    
    func getThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
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
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        thumbnailImage.image = nil
    }
}
