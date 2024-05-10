//
//  FirebaseDatabaseManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabaseSwift
//import CodableFirebase

final class FirebaseDatabaseManager: FirebaseDatabaseManagerService {
    
    func multiLocationUpload(data: [FirebaseMultiUploadDataPoint], completion: @escaping (Result<Void, Error>) -> Void) {
        var keyPaths = [String: Any?]()
        for datum in data {
            keyPaths[datum.path] = datum.value
        }
        let dbref = Database.database().reference()
        dbref.updateChildValues(keyPaths) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Multi Location Async
    
    static let shared: FirebaseDatabaseManager = .init()
    
    private init() {}
    
    private var databaseHandles = Set<DatabaseHandle>()
    
    var databaseReference: DatabaseReference {
        #if EMULATOR
        return Database.database(url:"http://127.0.0.1:9000?ns=inthegym-2353b").reference()
        #else
        return Database.database().reference()
        #endif
    }
    
    func removeObserver(with handle: DatabaseHandle) {
        databaseHandles.remove(handle)
        databaseReference.removeObserver(withHandle: handle)
    }
    
    func fetchInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
        let DBRef = databaseReference.child(model.internalPath)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError()))
                return
            }
            do {
                let data = try children.compactMap { try? $0.data(as: returnType) }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchSingleObjectInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
        let DBRef = databaseReference.child(model.internalPath)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError()))
                return
            }
            do {
                let data = try children.compactMap { try $0.data(as: returnType) }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    

    
    func fetchRange<M: FirebaseInstance, T: Decodable>(from models: [M], returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
        var tempModels = [T]()
        let dispatchGroup = DispatchGroup()
        let dbref = databaseReference
        for model in models {
            dispatchGroup.enter()
            dbref.child(model.internalPath).observeSingleEvent(of: .value) { snapshot in
                defer { dispatchGroup.leave() }
                do {
                    let data = try snapshot.data(as: returnType)
                    tempModels.insert(data, at: 0)
                } catch {
                    print(String(describing: error))
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(tempModels))
        }
    }
    
    // MARK: - Fetch Range Async

    
    // MARK: - Fetch Keys
    func fetchKeys<M: FirebaseInstance>(from model: M, completion: @escaping (Result<[String],Error>) -> Void) {
        var tempKeys = [String]()
        let dbref = databaseReference.child(model.internalPath)
        dbref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                tempKeys.insert(child.key, at: 0)
            }
            completion(.success(tempKeys))
        }
    }
    // MARK: - Fetch Keys Async

    
    func upload<Model: FirebaseInstance>(data: Model, autoID: Bool, completion: @escaping (Result<Void,Error>) -> Void) {
        let dbref = databaseReference.child(data.internalPath)
        if autoID {
            dbref.childByAutoId()
        }
        do {
            try dbref.setValue(from: data)
            completion(.success(()))
        }
        catch {
            completion(.failure(error))
        }
    }
    


    
    
    
    // MARK: - Check Existence
    func checkExistence<Model:FirebaseInstance>(of model: Model, completion: @escaping(Result<Bool,Error>) -> Void) {
        let dbref = databaseReference.child(model.internalPath)
        dbref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
    }
    
    // MARK: - Time Ordered Upload
    func uploadTimeOrderedModel<Model: FirebaseTimeOrderedModel>(model: Model, completion: @escaping (Result<Model,Error>) -> Void) {
        print(model.internalPath)
        let dbref = databaseReference.child(model.internalPath).childByAutoId()
        let autoID = dbref.key
        var uploadModel = model
        uploadModel.id = autoID!
        do {
            try dbref.setValue(from: uploadModel)
            completion(.success(uploadModel))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    
    func fetchLimited<Model: FirebaseModel>(model: Model.Type, limit: Int, completion: @escaping (Result<[Model],Error>) -> Void) {
        let dbref = databaseReference.child(model.path).queryLimited(toLast: UInt(limit))
        dbref.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError()))
                return
            }
            do {
                let data = try children.compactMap { try $0.data(as: model) }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    func fetchLimitedInstance<Model: FirebaseInstance, T: Decodable>(of model: Model, returning returnType: T.Type, limit: Int, completion: @escaping (Result<[T],Error>) -> Void) {
        let dbRef = databaseReference.child(model.internalPath).queryLimited(toLast: UInt(limit))
        dbRef.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError()))
                return
            }
            do {
                let data = try children.compactMap { try $0.data(as: returnType) }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
         }
    }
    
    // MARK: - Async Functions
    func fetchAsync<Model: FirebaseModel>() async throws -> [Model] {
        let ref = databaseReference.child(Model.path)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshto children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: Model.self) }
        return data
    }
    func fetchInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> [T] {
        let ref = databaseReference.child(model.internalPath)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshto children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: T.self) }
        return data
    }
    func fetchSingleInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> T {
        let ref = databaseReference.child(model.internalPath)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        let data = try snapshot.data(as: T.self)
        return data
    }
    
    func uploadAsync<Model: FirebaseInstance>(data: Model) async throws {
        let dbref = databaseReference.child(data.internalPath)
        try await dbref.setValue(data)
    }
    func upload(data: Codable, at path: String) async throws {
        let ref = databaseReference.child(path)
        try ref.setValue(from: data)
    }

    
    func multiLocationUploadAsync(data: [FirebaseMultiUploadDataPoint]) async throws {
        var keyPaths = [AnyHashable: Any?]()
        for datum in data {
            keyPaths[datum.path] = datum.value
        }
        let ref = databaseReference
        try await ref.updateChildValues(keyPaths as [AnyHashable : Any])
    }
    
    func fetchKeysAsync<M: FirebaseInstance>(from model: M) async throws -> [String] {
        let ref = databaseReference.child(model.internalPath)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshot children", code: 0)
        }
        let keys = children.map { $0.key }
        return keys
    }
    func fetchRangeAsync<M: FirebaseInstance, T: Decodable>(from models: [M]) async throws -> [T] {
        var tempModels = [T]()
        let dbref = databaseReference
        for model in models {
            let (snapshot, _) = await dbref.child(model.internalPath).observeSingleEventAndPreviousSiblingKey(of: .value)
            do {
                let data = try snapshot.data(as: T.self)
                tempModels.insert(data, at: 0)
            } catch {
                print(String(describing: error))
            }
        }
        return tempModels
    }
    
    func checkExistenceAsync<Model:FirebaseInstance>(of model: Model) async throws -> Bool {
        let dbref = databaseReference.child(model.internalPath)
        let (snapshot, _) = await dbref.observeSingleEventAndPreviousSiblingKey(of: .value)
        return snapshot.exists()
    }
    func checkExistence(at path: String) async throws -> Bool {
        let ref = databaseReference.child(path)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        return snapshot.exists()
    }
    func childCountAsync<Model:FirebaseInstance>(of model: Model) async throws -> Int {
        let dbref = databaseReference.child(model.internalPath)
        let (snapshot, _) = await dbref.observeSingleEventAndPreviousSiblingKey(of: .value)
        if snapshot.exists() {
            return Int(snapshot.childrenCount)
        } else {
            return 0
        }
    }
    
    func uploadTimeOrderedModelAsync<Model: FirebaseTimeOrderedModel>(data: inout Model) async throws -> Model {
        let ref = databaseReference.child(data.internalPath).childByAutoId()
        guard let autoID = ref.key else {
            throw NSError(domain: "Cant generate auto ID", code: -1)
        }
        data.id = autoID
        try ref.setValue(from: data)
        return data
    }
    
    func fetchLimitedAsync<Model: FirebaseModel>(model: Model.Type, limit: Int) async throws -> [Model] {
        let ref = databaseReference.child(model.path).queryLimited(toLast: UInt(limit))
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshto children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: Model.self) }
        return data
    }
    
    func searchTextQueryModelAsync<Model: FirebaseQueryModel, T: Decodable>(model: Model) async throws -> [T] {
        let ref = databaseReference.child(model.internalPath)
            .queryOrdered(byChild: model.orderedBy)
            .queryStarting(atValue: model.equalTo)
            .queryEnding(atValue: model.equalTo+"\u{f8ff}")
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshot children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: T.self) }
        return data
    }
    func fetchSingleObjectInstanceAsync<M: FirebaseInstance, T: Decodable>(of model: M) async throws -> [T] {
        let ref = databaseReference.child(model.internalPath)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshto children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: T.self) }
        return data
    }
    func fetchLimitedInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model, limit: Int) async throws -> [T] {
        let ref = databaseReference.child(model.internalPath).queryLimited(toLast: UInt(limit))
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshot children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: T.self) }
        return data
    }
    
    func read<T: Codable>(at path: String) async throws -> T {
        let ref = databaseReference.child(path)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        let data = try snapshot.data(as: T.self)
        return data
    }
    func readAll<T: Codable>(at path: String) async throws -> [T] {
        let ref = databaseReference.child(path)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshot children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: T.self) }
        return data
    }
}

protocol FirebaseDatabaseManagerService {
    
    func fetchInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func upload<Model: FirebaseInstance>(data: Model, autoID: Bool, completion: @escaping (Result<Void,Error>) -> Void)
    func multiLocationUpload(data: [FirebaseMultiUploadDataPoint], completion: @escaping(Result<Void,Error>) -> Void)
//    func incrementingValue(by increment: Int, at path: String, completion: @escaping(Result<Void,Error>) -> Void)
//    func removingValue(at path: String, completion: @escaping(Result<Void,Error>) -> Void)
    func fetchKeys<M: FirebaseInstance>(from model: M, completion: @escaping (Result<[String],Error>) -> Void)
    func fetchRange<M: FirebaseInstance, T: Decodable>(from models: [M], returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func checkExistence<Model:FirebaseInstance>(of model: Model, completion: @escaping(Result<Bool,Error>) -> Void)
    func uploadTimeOrderedModel<Model: FirebaseTimeOrderedModel>(model: Model, completion: @escaping (Result<Model,Error>) -> Void)
//    func searchQueryModel<Model: FirebaseQueryModel, T: Decodable>(model: Model, returning: T.Type, completion: @escaping (Result<T,Error>) -> Void)
    func fetchLimited<Model: FirebaseModel>(model: Model.Type, limit: Int, completion: @escaping (Result<[Model],Error>) -> Void)
    func fetchSingleObjectInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func fetchLimitedInstance<Model: FirebaseInstance, T: Decodable>(of model: Model, returning returnType: T.Type, limit: Int, completion: @escaping (Result<[T],Error>) -> Void)
    
    // MARK: Async
    func fetchAsync<Model: FirebaseModel>() async throws -> [Model]
    func fetchInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> [T]
    func fetchSingleInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> T
    
    func uploadAsync<Model: FirebaseInstance>(data: Model) async throws
    func multiLocationUploadAsync(data: [FirebaseMultiUploadDataPoint]) async throws
    
    func fetchKeysAsync<M: FirebaseInstance>(from model: M) async throws -> [String]
    func fetchRangeAsync<M: FirebaseInstance, T: Decodable>(from models: [M]) async throws -> [T]
    
    func checkExistenceAsync<Model:FirebaseInstance>(of model: Model) async throws -> Bool
    func childCountAsync<Model:FirebaseInstance>(of model: Model) async throws -> Int
    
    func uploadTimeOrderedModelAsync<Model: FirebaseTimeOrderedModel>(data: inout Model) async throws -> Model
    
    func fetchLimitedAsync<Model: FirebaseModel>(model: Model.Type, limit: Int) async throws -> [Model]
    
    func searchTextQueryModelAsync<Model: FirebaseQueryModel, T: Decodable>(model: Model) async throws -> [T]
    func fetchSingleObjectInstanceAsync<M: FirebaseInstance, T: Decodable>(of model: M) async throws -> [T]
    func fetchLimitedInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model, limit: Int) async throws -> [T]
    
    // MARK: - Modular
    func checkExistence(at path: String) async throws -> Bool
    func upload(data: Codable, at path: String) async throws
    func read<T:Codable>(at path: String) async throws -> T
    func readAll<T:Codable>(at path: String) async throws -> [T]
 }
