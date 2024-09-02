//
//  RemoteWorkoutUploader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public class RemoteWorkoutUploader {
    
    let uploader: WorkoutUploader
    let model: UploadWorkoutModel
    
    public init(uploader: WorkoutUploader, model: UploadWorkoutModel) {
        self.uploader = uploader
        self.model = model
    }
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public typealias Result = WorkoutUploader.Result
    
    public func upload(completion: @escaping (Result) -> Void) {
        uploader.upload(model) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success:
                completion(.success(true))
            }
        }
    }
}
