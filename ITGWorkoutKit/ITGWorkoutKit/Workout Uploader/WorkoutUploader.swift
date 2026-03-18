//
//  WorkoutUploader.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public protocol WorkoutUploader {
    typealias Result = Swift.Result<Bool, Error>
    
    func upload(_ model: UploadWorkoutModel, completion: @escaping (Result) -> Void)
}
