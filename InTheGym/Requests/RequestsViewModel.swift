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
    }
 
    
    // MARK: - Fetching functions
    func fetchData(){
        self.isLoading = true
        
        var tempRequest = [Users]()
        let myGroup = DispatchGroup()
        
        let requestsRef = Database.database().reference().child("PlayerRequests").child(self.userID)
        requestsRef.observe(.value) { (snapshot) in
            
            if snapshot.childrenCount == 0 {
                self.requests = []
                self.isLoading = false
            }
            for child in snapshot.children{
                myGroup.enter()
                UserIDToUser.transform(userID: (child as AnyObject).key) { (user) in
                    tempRequest.append(user)
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main){
                self.requests = tempRequest
                self.isLoading = false
            }
        }
    }
    
    
    
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> Users {
        return requests[indexPath.row]
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
        
        // post for self
        let actData = ["time":ServerValue.timestamp(),
                       "type":"Request Accepted",
                       "message":"You accepted a request from \(user.username!).",
                       "isPrivate":true,
                       "posterID":self.userID] as [String:AnyObject]
        let postRef = Database.database().reference().child("Posts").childByAutoId()
        let postRefKey = postRef.key
        postRef.setValue(actData)
        let posselfreferences = Database.database().reference().child("PostSelfReferences").child(self.userID).child(postRefKey!)
        posselfreferences.setValue(true)
        let timelineref = Database.database().reference().child("Timeline").child(self.userID).child(postRefKey!)
        timelineref.setValue(true)
        
        UserIDToUser.transform(userID: self.userID) { (selfuser) in
            // post for coach
            let coachActData = ["time":ServerValue.timestamp(),
                                "type":"Request Accepted",
                                "message":"\(selfuser.username!) accepted your request.",
                                "isPrivate":true,
                                "posterID":user.uid!] as [String:AnyObject]
            
            let coachPostRef = Database.database().reference().child("Posts").childByAutoId()
            let coachPostRefKey = coachPostRef.key
            coachPostRef.setValue(coachActData)
            let coachposselfreferences = Database.database().reference().child("PostSelfReferences").child(user.uid!).child(coachPostRefKey!)
            coachposselfreferences.setValue(true)
            let coachtimelineref = Database.database().reference().child("Timeline").child(user.uid!).child(coachPostRefKey!)
            coachtimelineref.setValue(true)
        }
        

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
