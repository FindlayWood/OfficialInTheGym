//
//  ImageAPIService.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ImageAPIService {
    
    static var shared = ImageAPIService()
    
    private init(){}
    
    let cache = NSCache<NSString,UIImage>()
    
    private func downloadImage(with imageURL:String, completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: imageURL)
            let data = NSData(contentsOf: url!)
            let image = UIImage(data: data! as Data)
            
            if image != nil {
                self.cache.setObject(image!, forKey: url!.absoluteString as NSString)
            }
            
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func getImage(with imageURL:String, completion: @escaping (UIImage?) -> ()) {
        let url = URL(string: imageURL)
        if let image = cache.object(forKey: url!.absoluteString as NSString){
            completion(image)
        } else {
            downloadImage(with: imageURL, completion: completion)
        }
           
    }
    
    
    
}
