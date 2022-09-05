//
//  DatabaseEndpoints.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

enum TimelineEndpoints : TimelineEndPointProtocol {
    
    case getTimeline(id:String)
    case getPublicTimeline(following:Bool, id:String)
    
    var path : String {
        switch self {
        case .getTimeline(let id):
            return "Timeline/\(id)"
        case .getPublicTimeline( _, let id):
            return "PostSelfReferences/\(id)"
        }
    }
}


protocol TimelineEndPointProtocol {
    var path : String {get}
}
extension TimelineEndPointProtocol{
    
    func retreive(completion: @escaping (Result<[PostProtocol], Error>) -> () ){
        //FirebaseAPI.shared().get(from: self.path, completion: completion)
    }
}



enum DatabaseEndpoints: DatabaseEndpoint{
    case getTimeline(id:String)
    case getWorkouts(id:String)
    case getPlayers(id:String)
    case getProfileTimeline
    
    var path: String {
        switch self {
        case .getTimeline(let id):
            return "Timeline/\(id)"
        case .getWorkouts(let id):
            return "Workouts/\(id)"
        case .getPlayers(let id):
            return "CoachPlayers/\(id)"
        case .getProfileTimeline:
            return "PostSelfReferences"
        }
    }
}


protocol DatabaseEndpoint {
    var path : String {get}
}
extension DatabaseEndpoint{
    func retreive<T:Codable>(expectedReturnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void){
//        FirebaseAPI.shared().retreive(from: self.path, expectingReturnType: expectedReturnType, completion: completion)
    }
    
    func retreiveProfileTimeline(completion: @escaping (Result<[PostProtocol], Error>) -> Void) {
//        FirebaseAPI.shared().loadProfileTimelineReferences(from: self.path, completion: completion)
    }
    
    func post(){
        
    }
}
