//
//  RequestsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class RequestsViewModel{
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var acceptedRequestClosure: (() -> ())?
    var declineRequestClosure: (() -> ())?
    
    // MARK: - Properties
    
    // We defined the FakeAPIServiceProtocol in the FakeAPIService.swift file.
    // We also defined a class and make it conform to that protocol.
    var apiService: DatabaseReference
    let userID = Auth.auth().currentUser!.uid
    let requestsRef  : DatabaseReference!
    var handle : DatabaseHandle!

    // This will contain info about the picture eventually selectded by the user by tapping an item on the screen
    var selectedUser: Users?
    
    // The collection that will contain our fetched data
    private var requests: [Users] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        return requests.count
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    // MARK: - Constructor
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(apiService: DatabaseReference) {
        self.apiService = apiService
        self.requestsRef = Database.database().reference().child("PlayerRequests").child(self.userID)
    }
 
    
    // MARK: - Fetching functions
    func fetchData(){
        self.isLoading = true
        
        var tempRequest = [String]()
        var initialLoad = true
        
        handle = requestsRef.observe(.childAdded) { (snapshot) in
            if initialLoad {
                tempRequest.append(snapshot.key)
            } else {
                self.addRequest(with: snapshot.key)
            }
        }
        
        requestsRef.observeSingleEvent(of: .value) { (snapshot) in
            // run function to load requeters
            if tempRequest.isEmpty {
                self.isLoading = false
            } else {
                self.loadRequests(with: tempRequest)
            }
            initialLoad = false
        }
    }
    
    func loadRequests(with userIDs : [String]) {
        var tempRequests = [Users]()
        let myGroup = DispatchGroup()
        for id in userIDs {
            myGroup.enter()
            UserIDToUser.transform(userID: id) { (user) in
                tempRequests.append(user)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            self.requests = tempRequests
            self.isLoading = false
        }
    }
    
    func addRequest(with id : String) {
        UserIDToUser.transform(userID: id) { (user) in
            self.requests.append(user)
        }
    }

    
    // MARK: - Remove Observer
    func removeObserver(){
        requestsRef.removeObserver(withHandle: handle)
    }
    
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> Users {
        return requests[indexPath.section]
    }
    
    func acceptRequest(from user:Users, at index:IndexPath){
        let myGroup = DispatchGroup()
        
        myGroup.enter()
        myGroup.enter()
        myGroup.enter()
        myGroup.enter()
        
        let playerRequestRef = Database.database().reference().child("PlayerRequests").child(userID).child(user.uid!)
        playerRequestRef.setValue(nil)
        { (error:Error?, ref:DatabaseReference) in
            defer {myGroup.leave()}
            if let error = error{ print(error)}
        }
        let coachRequestRef = Database.database().reference().child("CoachRequests").child(user.uid!).child(userID)
        coachRequestRef.setValue(nil){ (error:Error?, ref:DatabaseReference) in
            defer {myGroup.leave()}
            if let error = error{ print(error)}
        }
        let playerRef = Database.database().reference().child("CoachPlayers").child(user.uid!).child(userID)
        playerRef.setValue(true){ (error:Error?, ref:DatabaseReference) in
            defer {myGroup.leave()}
            if let error = error{ print(error)}
        }
        let coachRef = Database.database().reference().child("PlayerCoaches").child(userID).child(user.uid!)
        coachRef.setValue(true){ (error:Error?, ref:DatabaseReference) in
            defer {myGroup.leave()}
            if let error = error{ print(error)}
        }
        myGroup.notify(queue: .main){
            self.requests.remove(at: index.row)
            self.acceptedRequestClosure?()
        }
        
        FirebaseAPI.shared().uploadActivity(with: .NewCoach(user.username!))
        
        FirebaseAPI.shared().uploadActivity(with: .RequestAccepted(ViewController.username!, user.uid!))
        let notification = NotificationAcceptedRequest(from: self.userID, to: user.uid!)
        let uploadNotification = NotificationManager(delegate: notification)
        uploadNotification.upload()
    }
    
    func declinedRequest(from user:Users, at index:IndexPath){
        let playerRequestRef = Database.database().reference().child("PlayerRequests").child(userID).child(user.uid!)
        playerRequestRef.setValue(nil)
        let coachRequestRef = Database.database().reference().child("CoachRequests").child(user.uid!).child(userID)
        coachRequestRef.setValue(nil)
        self.requests.remove(at: index.row)
        self.declineRequestClosure?()
    }
    
    
    
}
