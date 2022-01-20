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
    func multiLocationUpload(data: [FirebaseMultiUploadDataPoint], completion: @escaping (Result<Void, Error>) -> Void) {
        var keyPaths = [String:Any]()
        for datum in data {
            keyPaths[datum.path] = datum.value
        }
        print(keyPaths)
    }
    
    func incrementingValue(by increment: Int, at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    func removingValue(at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    
    static let shared: FirebaseDatabaseManager = .init()
    
    private init() {}
    
    private var databaseHandles = Set<DatabaseHandle>()
    
    let databaseReference: DatabaseReference = Database.database().reference()
    
    func removeObserver(with handle: DatabaseHandle) {
        databaseHandles.remove(handle)
        databaseReference.removeObserver(withHandle: handle)
    }
    
    func fetch<Model: FirebaseModel>(_ model: Model.Type, completion: @escaping(Result<[Model],Error>) -> Void) {
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
    func fetchInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
        var tempModels = [T]()
        let DBRef = Database.database().reference().child(model.internalPath)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let object = child.value as? [String: AnyObject] else {return}
                do {
                    let data = try FirebaseDecoder().decode(returnType, from: object)
                    tempModels.insert(data, at: 0)
                }
                catch {
                    print(String(describing: error))
                }
            }
            completion(.success(tempModels))
        }
    }
    
    func fetchSingleInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<T,Error>) -> Void) {
        let DBRef = Database.database().reference().child(model.internalPath)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            guard let object = snapshot.value as? [String: AnyObject] else {return}
            do {
                let data = try FirebaseDecoder().decode(returnType, from: object)
                completion(.success(data))
            }
            catch {
                print(String(describing: error))
            }
        }
    }
    
    func fetchRange<M: FirebaseInstance, T: Decodable>(from models: [M], returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
        var tempModels = [T]()
        let dispatchGroup = DispatchGroup()
        let dbref = Database.database().reference()
        for model in models {
            dispatchGroup.enter()
            dbref.child(model.internalPath).observeSingleEvent(of: .value) { snapshot in
                guard let object = snapshot.value as? [String: AnyObject] else {return}
                do {
                    let data = try FirebaseDecoder().decode(returnType, from: object)
                    tempModels.insert(data, at: 0)
                    dispatchGroup.leave()
                }
                catch {
                    print(String(describing: error))
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(tempModels))
        }
    }
    
    func fetchKeys<M: FirebaseModel>(from model: M.Type, completion: @escaping (Result<[String],Error>) -> Void) {
        var tempKeys = [String]()
        let dbref = Database.database().reference().child(M.path)
        dbref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                tempKeys.insert(child.key, at: 0)
            }
            completion(.success(tempKeys))
        }
    }
    
    func upload<Model: FirebaseInstance>(data: Model, autoID: Bool, completion: @escaping (Result<Void,Error>) -> Void) {
        let dbref = Database.database().reference().child(data.internalPath)
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
    
    func checkExistence<Model:FirebaseInstance>(of model: Model, completion: @escaping(Result<Bool,Error>) -> Void) {
        let dbref = Database.database().reference().child(model.internalPath)
        dbref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
    }
}

protocol FirebaseDatabaseManagerService {
    func fetch<Model: FirebaseModel>(_ model: Model.Type, completion: @escaping(Result<[Model],Error>) -> Void)
    func fetchInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func fetchSingleInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<T,Error>) -> Void)
    func upload<Model: FirebaseInstance>(data: Model, autoID: Bool, completion: @escaping (Result<Void,Error>) -> Void)
    func multiLocationUpload(data: [FirebaseMultiUploadDataPoint], completion: @escaping(Result<Void,Error>) -> Void)
    func incrementingValue(by increment: Int, at path: String, completion: @escaping(Result<Void,Error>) -> Void)
    func removingValue(at path: String, completion: @escaping(Result<Void,Error>) -> Void)
    func fetchKeys<M: FirebaseModel>(from model: M.Type, completion: @escaping (Result<[String],Error>) -> Void)
    func fetchRange<M: FirebaseInstance, T: Decodable>(from models: [M], returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func checkExistence<Model:FirebaseInstance>(of model: Model, completion: @escaping(Result<Bool,Error>) -> Void)
}
