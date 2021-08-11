//
//  FirebaseAPIGroupService.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseAPIGroupServiceProtocol {
    func createGroup(with data: NewGroupModel, completion: @escaping (Bool) -> Void)
}

class FirebaseAPIGroupService: FirebaseAPIGroupServiceProtocol {
    static let shared = FirebaseAPIGroupService()
    private init() {}
    private var baseRef: DatabaseReference = Database.database().reference()
    
    func createGroup(with data: NewGroupModel, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let newGroupData = ["title": data.title,
                            "description": data.description,
                            "leader": userID] as [String: Any]
        
        let groupRef = baseRef.child("Groups").childByAutoId()
        let groupID = groupRef.key!
        
        var updatedGroupData: [String: Any] = [:]

        
        var membersData: [String: Bool] = [:]
        membersData[userID] = true
        updatedGroupData["GroupsReferences/\(userID)/\(groupID)"] = true
        
        for player in data.players {
            guard let playerID = player.uid else {return}
            membersData[playerID] = true
            updatedGroupData["GroupsReferences/\(playerID)/\(groupID)"] = true
        }
        
        updatedGroupData["Groups/\(groupID)"] = newGroupData
        updatedGroupData["GroupMembers/\(groupID)"] = membersData
        updatedGroupData["GroupsLeaderReferences/\(userID)/\(groupID)"] = true
        
        baseRef.updateChildValues(updatedGroupData) { error, ref in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }

    }
}
