//
//  FirebaseDatabaseEndpoints.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol FirebaseDatabaseEndpoints {
    var path: String { get }
}
protocol SingleDatabaseEndpoint {
    var path: String? { get }
}
protocol MultipleDatabaseEndpoint {
    var paths: [String:Any] { get }
}

protocol WorkoutEndpoint {
    var path: String { get }
    var workout: WorkoutDelegate { get }
    var service: FirebaseDatabaseWorkoutManagerService { get }
}

protocol PostEndpoint: SingleDatabaseEndpoint {
    var post: CreateNewPostModel? { get }
}
