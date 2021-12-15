//
//  FirebaseDatabaseManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

final class FirebaseDatabaseManager: FirebaseDatabaseManagerService {
    func multiLocationUpload(data: [String : Any], path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    func incrementingValue(by increment: Int, at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    func removingValue(at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    
    static let shared: FirebaseDatabaseManager = .init()
    
    private init() {}
    
    func fetch<Model: FirebaseResource>(_ model: Model.Type, completion: @escaping(Result<[Model],Error>) -> Void) {
        var tempModels = [Model]()
        let DBRef = Database.database().reference().child(Model.path)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let object = child.value as? [String: AnyObject] else {return}
                do {
                    let data = try FirebaseDecoder().decode(model, from: object)
                    tempModels.insert(data, at: 0)
                }
                catch {
                    print(String(describing: error))
                }
            }
            completion(.success(tempModels))
        }
    }
    func upload<Model: FirebaseResource>(_ model: Model.Type, data: Model, autoID: Bool, completion: @escaping (Result<Void,Error>) -> Void) {
        let dbref = Database.database().reference().child(Model.path)
        if autoID {
            dbref.childByAutoId()
        }
        do {
            let firebaseData = try FirebaseEncoder().encode(data)
            dbref.setValue(firebaseData) { error, ref in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
}

protocol FirebaseDatabaseManagerService {
    func fetch<Model: FirebaseResource>(_ model: Model.Type, completion: @escaping(Result<[Model],Error>) -> Void)
    func upload<Model: FirebaseResource>(_ model: Model.Type, data: Model, autoID: Bool, completion: @escaping (Result<Void,Error>) -> Void)
    func multiLocationUpload(data: [String:Any], path: String, completion: @escaping(Result<Void,Error>) -> Void)
    func incrementingValue(by increment: Int, at path: String, completion: @escaping(Result<Void,Error>) -> Void)
    func removingValue(at path: String, completion: @escaping(Result<Void,Error>) -> Void)
}
