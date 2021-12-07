//
//  DisplayingWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import CloudKit

class DisplayingWorkoutsViewModel {
    
    var workouts = CurrentValueSubject<[WorkoutModel], Error> ([WorkoutModel]())
    
    var subscriptions = Set<AnyCancellable>()
    
    var apiService: WorkoutLoader
    
    init(apiService: WorkoutLoader = .shared) {
        self.apiService = apiService
        setUpSubscriptions()
    }
    
    func setUpSubscriptions() {
        
        apiService.loadGenerically(WorkoutModel.self)
            .sink { _ in
                print("there was an error")
            } receiveValue: { loadedWorkouts in
                //print(loadedWorkouts)
                self.workouts.send(loadedWorkouts)
            }
            .store(in: &subscriptions)

    }
}

import Firebase
import AVFoundation
import CodableFirebase
import Combine
import FirebaseDatabase
class WorkoutLoader {
    static let shared = WorkoutLoader()
    private init() {}
    
    func fetchModel<Model>(_ model: Model.Type, completion: @escaping(Result<[Model],Error>) -> Void) where Model: FirebaseResource {
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
                    //completion(.failure(error))
                }
            }
            completion(.success(tempModels))
        }
    }
    
    func uploadModel<Model>(_ model: Model.Type, data: Model, autoID: Bool, completion: @escaping (Result<Void,Error>) -> Void) where Model: FirebaseResource {
        let dbref = Database.database().reference().child(Model.path)
        if autoID {
            dbref.childByAutoId()
        }
        do {
            let firebaseData = try FirebaseEncoder().encode(data)
            dbref.setValue(firebaseData)
            completion(.success(()))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func loadGenerically<Model>(_ model: Model.Type) -> Future<[Model], Error> where Model: FirebaseResource {
        Future { [unowned self] promise in
            self.fetchModel(model) { result in
                switch result {
                case .success(let models):
                    promise(.success(models))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    func loadWorkouts() -> Future<[WorkoutModel], Error> {
        Future { [unowned self] promise in
            self.load { result in
                switch result {
                case .success(let workouts):
                    promise(.success(workouts))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    
    
    func load(completion: @escaping(Result<[WorkoutModel],Error>) -> Void) {
        
//        let myGroup = DispatchGroup()
        var tempWorkouts = [WorkoutModel]()
        let dbref = Database.database().reference().child("Workouts").child(FirebaseAuthManager.currentlyLoggedInUser.uid)
//        dbref.observeSingleEvent(of: .value) { snapshot in
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                myGroup.enter()
//                guard let workoutObject = child.value as? [String: AnyObject] else {return}
//                do {
//                    let workoutData = try FirebaseDecoder().decode(WorkoutModel.self, from: workoutObject)
//                    tempWorkouts.append(workoutData)
//                    myGroup.leave()
//                }
//                catch {
//                    myGroup.leave()
//                }
//            }
//            myGroup.notify(queue: .main) {
//                completion(.success(tempWorkouts))
//            }
//        }
        
        dbref.observe(.value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let workoutObject = child.value as? [String:AnyObject] else {return}
                do {
                    let workoutData = try FirebaseDecoder().decode(WorkoutModel.self, from: workoutObject)
                    tempWorkouts.insert(workoutData, at: 0)
                }
                catch {
                    print(String(describing: error))
                }
            }
            completion(.success(tempWorkouts))
        }

        
//        dbref.observeSingleEvent(of: .value) { snapshot in
//            for child in snapshot.children.allObjects as! [DataSnapshot] {
//                guard let workoutObject = child.value as? [String:AnyObject] else {return}
//                do {
//                    let workoutData = try FirebaseDecoder().decode(WorkoutModel.self, from: workoutObject)
//                    tempWorkouts.insert(workoutData, at: 0)
//                }
//                catch {
//                    print(String(describing: error))
//                }
//            }
//            completion(.success(tempWorkouts))
//            
////            if let snap = snapshot.value as? [[String:AnyObject]] {
////                do {
////                    let workouts = try FirebaseDecoder().decode([WorkoutModel].self, from: snap)
////                    completion(.success(workouts))
////                }
////                catch {
////                    completion(.failure(error))
////                }
////            }
//        } withCancel: { error in
//            completion(.failure(error))
//        }
    }
}
