//
//  ImageAPIService.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ImageAPIService {
    
    static var shared = ImageAPIService()
    
    private var imageURLString : String!
    
    private init(){}
    
    let profileImageCache = NSCache<NSString,UIImage>()
    let cache = NSCache<NSString,UIImage>()
    
    private func downloadFirebaseImage(for userID:String, completion: @escaping (UIImage?) -> ()) {
        let storage = Storage.storage().reference().child("ProfilePhotos/\(userID)")
        storage.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = data{
                let image = UIImage(data: data)
                completion(image)
                self.profileImageCache.setObject(image!, forKey: userID as NSString)
            }
        }
    }
    
    func getProfileImage(for userID:String, completion: @escaping (UIImage?) -> ()) {
        if let image = profileImageCache.object(forKey: userID as NSString) {
            completion(image)
        } else {
            downloadFirebaseImage(for: userID, completion: completion)
        }
    }
    
    
    
    private func downloadImage(with imageURL:URL, completion: @escaping (UIImage?) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: imageURL) { data, responseURL, error in
            var downloadedImage:UIImage?
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let data = data {
                downloadedImage = UIImage(data: data)
            }

            if downloadedImage != nil {
                self.cache.setObject(downloadedImage!, forKey: imageURL.absoluteString as NSString)
            }

            DispatchQueue.main.async {
                completion(downloadedImage)
            }

        }
        dataTask.resume()


//        DispatchQueue.global(qos: .background).async {
//            let url = URL(string: imageURL)
//            let data = NSData(contentsOf: url!)
//            let image = UIImage(data: data! as Data)
//
//            if image != nil {
//                self.cache.setObject(image!, forKey: url!.absoluteString as NSString)
//            }
//
//
//            DispatchQueue.main.async {
//                if self.imageURLString == imageURL{
//                    completion(image)
//                }
//
//            }
//        }
    }

    func getImage(with imageURL:String, completion: @escaping (UIImage?) -> ()) {
        imageURLString = imageURL
        let url = URL(string: imageURL)!
        if let image = cache.object(forKey: url.absoluteString as NSString){
            completion(image)
        } else {
            downloadImage(with: url, completion: completion)
        }

    }
    
    
    
}
