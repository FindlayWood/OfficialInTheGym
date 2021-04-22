//
//  FollowersViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FollowersViewModel {
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    
    // MARK: - Properties
    
    // We defined the FakeAPIServiceProtocol in the FakeAPIService.swift file.
    // We also defined a class and make it conform to that protocol.
    var apiService: DatabaseReference
    let userID = Auth.auth().currentUser!.uid
    var followersBool:Bool!

    // This will contain info about the picture eventually selectded by the user by tapping an item on the screen
    var selectedUser: Users?
    
    // The collection that will contain our fetched data
    private var followers: [Users] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        return followers.count
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    // MARK: - Constructor
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(apiService: DatabaseReference, followersBool:Bool) {
        self.apiService = apiService
        self.followersBool = followersBool
    }
 
    
    // MARK: - Fetching functions
    func fetchData(){
        self.isLoading = true
        
        var tempUsers = [Users]()
        let myGroup = DispatchGroup()
        
        let followersRef = Database.database().reference()
        
        switch followersBool {
        case true:
            followersRef.child("Followers").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.childrenCount != 0{
                    for child in snapshot.children{
                        myGroup.enter()
                        UserIDToUser.transform(userID: (child as AnyObject).key) { (user) in
                            tempUsers.append(user)
                            myGroup.leave()
                        }
                        myGroup.notify(queue: .main){
                            self.followers = tempUsers
                            self.isLoading = false
                        }
                    }
                }else{
                    self.isLoading = false
                }
            }
            
        case false:
            followersRef.child("Following").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.childrenCount != 0{
                    for child in snapshot.children{
                        myGroup.enter()
                        UserIDToUser.transform(userID: (child as AnyObject).key) { (user) in
                            tempUsers.append(user)
                            myGroup.leave()
                        }
                        myGroup.notify(queue: .main){
                            self.followers = tempUsers
                            self.isLoading = false
                        }
                    }
                }else{
                    self.isLoading = false
                }
                
            }
           
        default:
            print("default")
        }
    }
    
    
    
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> Users {
        return followers[indexPath.row]
    }
}
    
