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
        FirebaseAPI.shared().get(from: self.path, completion: completion)
    }
}
