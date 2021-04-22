//
//  MyGroupViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class MyGroupViewModel:NSObject {
    
    //MARK: - Database Reference
    var ref : DatabaseReference!
    var handle : DatabaseHandle!
    
    // MARK: - Closures
    var updateLoadingStatusClosure:(()->())?
    var myGroupsLoaded:(()->())?
    
    var isLoading: Bool = false {
        didSet{
            updateLoadingStatusClosure?()
        }
    }
    
    private var myGroups: [groupModel] = [] {
        didSet{
            myGroupsLoaded?()
        }
    }
    
    var numberOfGroups : Int {
        return myGroups.count
    }
    
    let userID = Auth.auth().currentUser!.uid
    
    override init(){
        self.ref = Database.database().reference().child("GroupsReferences").child(userID)
    }
    
    func fetchData(){
        self.isLoading = true
        var groupReferences = [String]()
        //let ref = Database.database().reference().child("GroupsReferences").child(userID)
        handle = ref.observe(.childAdded) { (snapshot) in
            groupReferences.append(snapshot.key)
        }
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists(){
                self.isLoading = false
            } else {
                self.fetchGroups(with: groupReferences)
            }
        }
    }
    
    func fetchGroups(with references:[String]){
        
        let ref = Database.database().reference().child("Groups")
        let myGroup = DispatchGroup()
        
        var tempGroups = [groupModel]()
        
        for group in references {
            myGroup.enter()
            ref.child(group).observeSingleEvent(of: .value) { (snapshot) in
                tempGroups.append(groupModel(snapshot: snapshot)!)
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main){
            self.myGroups = tempGroups
            self.isLoading = false
        }
        
    }
    
    //MARK: - Remove Observers
    func removeObservers(){
        self.ref.removeObserver(withHandle: handle)
    }
    
    // MARK: - Retreive functions
    func getGroup(at indexPath:IndexPath) -> groupModel{
        return myGroups[indexPath.section]
    }
}
