//
//  File.swift
//  
//
//  Created by Findlay-Personal on 11/05/2023.
//

import Foundation

public protocol StorageService {
    /// download data async
    /// - Parameters:
    ///   - path: The path to the location of data.
    ///   - maxSize: The maximum size in bytes to download. If the download exceeds this size, the task will be cancelled and an error will be returned.
    /// - Returns: Data
    func getData(at path: String, maxSize: Int64, completion: @escaping (Result<Data,Error>) -> Void)
    
//    func downloadImage(from path: String, completion: @escaping ((Result<UIImage,Error>) -> Void))
}
