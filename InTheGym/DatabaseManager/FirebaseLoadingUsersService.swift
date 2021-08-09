//
//  FirebaseLoadingUsersService.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseLoadUsersServiceProtocol {
    func loadPlayers(completion: @escaping (Result<[Users], LoadingUsersError>) -> Void)
}

enum LoadingUsersError: Error {
    case UserIDError
}

class FirebaseLoadingUsersService: FirebaseLoadUsersServiceProtocol {
    
    // MARK: - Shared Instance
    static let shared = FirebaseLoadingUsersService()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Properties
    var basePath: DatabaseReference = Database.database().reference()
    
    // MARK: - Methods
    func loadPlayers(completion: @escaping (Result<[Users], LoadingUsersError>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(.UserIDError))
            return
        }
        var players = [Users]()
        let myGroup = DispatchGroup()
        let path = basePath.child("CoachPlayers").child(userID)
        path.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children{
                myGroup.enter()
                UserIDToUser.transform(userID: (child as AnyObject).key) { (player) in
                    players.append(player)
                    myGroup.leave()
                }
                
            }
            myGroup.notify(queue: .main){
                completion(.success(players))
            }
        }
    }
}
