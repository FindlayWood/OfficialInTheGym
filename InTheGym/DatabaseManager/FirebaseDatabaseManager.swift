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
//        var tempModels = [Model]()
        let DBRef = Database.database().reference().child(Model.path)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError()))
                return
            }
            do {
                let data = try children.compactMap { try? $0.data(as: model) }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
            
            
            
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                guard let object = child.value as? [String: AnyObject] else {return}
//                do {
//                    let data = try FirebaseDecoder().decode(model, from: object)
//                    tempModels.insert(data, at: 0)
//                }
//                catch {
//                    print(String(describing: error))
//                }
//            }
//            completion(.success(tempModels))
        }
    }
    func fetchSingleModel<Model: FirebaseModel>(_ model: Model.Type, completion: @escaping (Result<Model,Error>) -> Void) {
        let DBRef = Database.database().reference().child(model.path)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            do {
                let data = try snapshot.data(as: model)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
//            guard let object = snapshot.value as? [String: AnyObject] else {return}
//            do {
//                let data = try FirebaseDecoder().decode(model, from: object)
//                completion(.success(data))
//            }
//            catch {
//                print(String(describing: error))
//                completion(.failure(error))
//            }
        }
    }
    func fetchInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
//        var tempModels = [T]()
        let DBRef = Database.database().reference().child(model.internalPath)
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
            
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                guard let object = child.value as? [String: AnyObject] else {return}
//                do {
//                    let data = try FirebaseDecoder().decode(returnType, from: object)
//                    tempModels.insert(data, at: 0)
//                }
//                catch {
//                    print(String(describing: error))
//                }
//            }
//            completion(.success(tempModels))
        }
    }
    
    func fetchInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> [T] {
        let ref = Database.database().reference().child(model.internalPath)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
            throw NSError(domain: "No snapshto children", code: 0)
        }
        let data = children.compactMap { try? $0.data(as: T.self) }
        return data
    }
    
    func fetchSingleInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<T,Error>) -> Void) {
        let DBRef = Database.database().reference().child(model.internalPath)
        DBRef.observeSingleEvent(of: .value) { snapshot in
            do {
                let data = try snapshot.data(as: returnType)
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
//            guard let object = snapshot.value as? [String: AnyObject] else {
//                completion(.failure(NSError(domain: "Invalid Infp", code: 0, userInfo: nil)))
//                return
//            }
//            do {
//                let data = try FirebaseDecoder().decode(returnType, from: object)
//                completion(.success(data))
//            }
//            catch {
//                print(String(describing: error))
//                completion(.failure(error))
//            }
        }
    }
    
    func fetchSingleObjectInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
//        var tempModels = [T]()
        let DBRef = Database.database().reference().child(model.internalPath)
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
            
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                guard let object = child.value as? T else {
//                    completion(.failure(NSError(domain: "wrong data type", code: 0, userInfo: nil)))
//                    return
//                }
//                do {
//                    let data = try FirebaseDecoder().decode(returnType, from: object)
//                    tempModels.insert(data, at: 0)
//                }
//                catch {
//                    print(String(describing: error))
//                }
//            }
//            completion(.success(tempModels))
        }
    }
    
    func fetchSingleInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> T {
        let ref = Database.database().reference().child(model.internalPath)
        let (snapshot, _) = await ref.observeSingleEventAndPreviousSiblingKey(of: .value)
        let data = try snapshot.data(as: T.self)
        return data
    }
    
    func fetchRange<M: FirebaseInstance, T: Decodable>(from models: [M], returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
        var tempModels = [T]()
        let dispatchGroup = DispatchGroup()
        let dbref = Database.database().reference()
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
//                guard let object = snapshot.value as? [String: AnyObject] else {return}
//                do {
//                    let data = try FirebaseDecoder().decode(returnType, from: object)
//                    tempModels.insert(data, at: 0)
//                }
//                catch {
//                    print(String(describing: error))
//                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(tempModels))
        }
    }
    
    // MARK: - Fetch Keys
    func fetchKeys<M: FirebaseInstance>(from model: M, completion: @escaping (Result<[String],Error>) -> Void) {
        var tempKeys = [String]()
        let dbref = Database.database().reference().child(model.internalPath)
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
            try dbref.setValue(from: data)
            completion(.success(()))
//            let firebaseData = try FirebaseEncoder().encode(data)
//            dbref.setValue(from: data) { error, ref in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(()))
//                }
//            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func uploadAsync<Model: FirebaseInstance>(data: Model) async throws {
        let dbref = Database.database().reference().child(data.internalPath)
        try await dbref.setValue(data)
    }
    func uploadTimeOrderedModelAsync<Model: FirebaseTimeOrderedModel>(data: inout Model) async throws -> Model {
        let ref = Database.database().reference().child(data.internalPath).childByAutoId()
        guard let autoID = ref.key else {
            throw NSError(domain: "Cant generate auto ID", code: -1)
        }
        data.id = autoID
        try ref.setValue(from: data)
        return data
    }
    
    
    
    // MARK: - Check Existence
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
    
    // MARK: - Child Count
    func childCount<Model:FirebaseInstance>(of model: Model, completion: @escaping (Result<Int,Error>) -> Void) {
        let dbref = Database.database().reference().child(model.internalPath)
        dbref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(.success(Int(snapshot.childrenCount)))
            } else {
                completion(.success(0))
            }
        }
    }
    
    // MARK: - Time Ordered Upload
    func uploadTimeOrderedModel<Model: FirebaseTimeOrderedModel>(model: Model, completion: @escaping (Result<Model,Error>) -> Void) {
        print(model.internalPath)
        let dbref = Database.database().reference().child(model.internalPath).childByAutoId()
        let autoID = dbref.key
        var uploadModel = model
        uploadModel.id = autoID!
//        print(uploadModel)
        do {
            try dbref.setValue(from: uploadModel)
            completion(.success(uploadModel))
//            let firebaseData = try FirebaseEncoder().encode(uploadModel)
//            print(firebaseData)
//            completion(.success(uploadModel))
//            dbref.setValue(firebaseData) { error, ref in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success((uploadModel)))
//                }
//            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func searchQueryModel<Model: FirebaseQueryModel, T: Decodable>(model: Model, returning: T.Type, completion: @escaping (Result<T,Error>) -> Void) {
        let dbref = Database.database().reference().child(model.internalPath).queryOrdered(byChild: model.orderedBy).queryEqual(toValue: model.equalTo)
        dbref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                do {
                    let data = try snapshot.data(as: returning)
                    completion(.success(data))
                } catch {
                    completion(.failure(error))
                }
                
//                for child in snapshot.children.allObjects as! [DataSnapshot] {
//                    if let object = child.value as? [String: AnyObject] {
//                        do {
//                            let data = try FirebaseDecoder().decode(returning, from: object)
//                            completion(.success(data))
//                        }
//                        catch {
//                            print(String(describing: error))
//                            completion(.failure(error))
//                        }
//                    } else {
//                        completion(.failure(NSError(domain: "No Object", code: 0, userInfo: nil)))
//                    }
//                }
            } else {
                completion(.failure(NSError(domain: "No Snapshot", code: -1, userInfo: nil)))
            }
        }
    }
    
    func fetchLimited<Model: FirebaseModel>(model: Model.Type, limit: Int, completion: @escaping (Result<[Model],Error>) -> Void) {
        let dbref = Database.database().reference().child(model.path).queryLimited(toLast: UInt(limit))
//        var tempModels = [Model]()
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
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                guard let object = child.value as? [String: AnyObject] else {return}
//                do {
//                    let data = try FirebaseDecoder().decode(model, from: object)
//                    tempModels.insert(data, at: 0)
//                }
//                catch {
//                    print(String(describing: error))
//                }
//            }
//            completion(.success(tempModels))
        }
    }
    func fetchLimitedInstance<Model: FirebaseInstance, T: Decodable>(of model: Model, returning returnType: T.Type, limit: Int, completion: @escaping (Result<[T],Error>) -> Void) {
        let dbRef = Database.database().reference().child(model.internalPath).queryLimited(toLast: UInt(limit))
//        var tempModels = [T]()
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
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                guard let object = child.value as? [String: AnyObject] else { return }
//                do {
//                    let data = try FirebaseDecoder().decode(returnType, from: object)
//                    tempModels.insert(data, at: 0)
//                } catch {
//                    print(String(describing: error))
//                }
//            }
//            completion(.success(tempModels))
         }
    }
    func searchTextQueryModel<Model: FirebaseQueryModel, T: Decodable>(model: Model, returning: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
//        var tempModels = [T]()
        let dbref = Database.database().reference().child(model.internalPath)
            .queryOrdered(byChild: model.orderedBy)
            .queryStarting(atValue: model.equalTo)
            .queryEnding(atValue: model.equalTo+"\u{f8ff}")
        dbref.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError()))
                return
            }
            do {
                let data = try children.compactMap { try $0.data(as: returning) }
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                guard let object = child.value as? [String: AnyObject] else {return}
//                do {
//                    let data = try FirebaseDecoder().decode(returning, from: object)
//                    tempModels.insert(data, at: 0)
//                }
//                catch {
//                    print(String(describing: error))
//                }
//            }
//            completion(.success(tempModels))

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
    func fetchKeys<M: FirebaseInstance>(from model: M, completion: @escaping (Result<[String],Error>) -> Void)
    func fetchRange<M: FirebaseInstance, T: Decodable>(from models: [M], returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func checkExistence<Model:FirebaseInstance>(of model: Model, completion: @escaping(Result<Bool,Error>) -> Void)
    func childCount<Model:FirebaseInstance>(of model: Model, completion: @escaping (Result<Int,Error>) -> Void)
    func uploadTimeOrderedModel<Model: FirebaseTimeOrderedModel>(model: Model, completion: @escaping (Result<Model,Error>) -> Void)
    func searchQueryModel<Model: FirebaseQueryModel, T: Decodable>(model: Model, returning: T.Type, completion: @escaping (Result<T,Error>) -> Void)
    func fetchLimited<Model: FirebaseModel>(model: Model.Type, limit: Int, completion: @escaping (Result<[Model],Error>) -> Void)
    func searchTextQueryModel<Model: FirebaseQueryModel, T: Decodable>(model: Model, returning: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func fetchSingleObjectInstance<M: FirebaseInstance, T: Decodable>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void)
    func fetchLimitedInstance<Model: FirebaseInstance, T: Decodable>(of model: Model, returning returnType: T.Type, limit: Int, completion: @escaping (Result<[T],Error>) -> Void)
    
    // MARK: Async
    func fetchSingleInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> T
    func uploadAsync<Model: FirebaseInstance>(data: Model) async throws
    func uploadTimeOrderedModelAsync<Model: FirebaseTimeOrderedModel>(data: inout Model) async throws -> Model
    func fetchInstanceAsync<Model: FirebaseInstance, T: Decodable>(of model: Model) async throws -> [T]
 }
