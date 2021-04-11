//
//  CreatedWorkoutUploadViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class CreatedWorkoutUploadViewModel {
    
    var updateLoadingStatusClosure:(()->())?
    var collectionReloaded:(()->())?
    
    let userID = Auth.auth().currentUser!.uid
    
    var isLoading : Bool = false {
        didSet{
            updateLoadingStatusClosure?()
        }
    }
    
    var data : [[String:AnyObject]] = [] {
        didSet{
            collectionReloaded?()
        }
    }
    
    var numberOfItems : Int {
        return data.count
    }
    
    var groupMembers : [String]?
    
    var createdFor : String!
    var noOfExercises : Int!
    var groupBool : Bool!
    
    init(createdFor:String, noOfExercises:Int, group: Bool){
        self.createdFor = createdFor
        self.noOfExercises = noOfExercises
        self.groupBool = group
    }

    
    func fetchData(){
        self.isLoading = true
        
        var tempData = [
                     ["title":"Exercises",
                      "label":"\(noOfExercises!)"],
                     ["title":"Public",
                      "image":UIImage(named: "public_icon")!,
                      "description":"This workout is public. This means that it can be viewed by everyone and it may appear on the discover page. Tap to change."],
                     ["title":"Add to Saved",
                      "image":UIImage(named: "Workout Completed")!,
                      "description":"Adding this workout to your saved workouts where you can add it to your workouts in the future. Tap to change."],
                     ["title":"Add to Created",
                      "image":UIImage(named: "Workout Completed")!,
                      "description":"Adding this workout to your created workout list. Your created workout list lets other users see the kind of workouts you create. We recommend adding all your workouts to your created workout list.Tap to Change."],
                     ["title":"Post to Timeline",
                      "image":UIImage(named: "Workout Completed")!,
                      "description":"Posting this workout to the timeline. Your followers and players/coaches will be able to see this workout on the timeline. Tap to change."],
            ] as [[String:AnyObject]]
        
        
        if groupBool == true {
            UserIDToUser.groupIdToGroupName(groupID: createdFor) { (group) in
                let createdInsert = ["title":"Created For:",
                                     "label":group.groupTitle] as [String:AnyObject]
                tempData.insert(createdInsert, at: 0)
                self.data = tempData
                self.isLoading = false
            }

        } else {
            UserIDToUser.transform(userID: createdFor) { (user) in
                let createdInsert = ["title":"Created For:",
                                     "label":user.username!] as [String:AnyObject]
                tempData.insert(createdInsert, at: 0)
                self.data = tempData
                self.isLoading = false
            }
            
            
            
            
        }
    }
    
    func upload(){
        if groupBool == true {
            let groupRef = Database.database().reference().child("GroupMembers").child(createdFor)
            groupRef.observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children{
                    let memberID:String = (child as AnyObject).key
                    if memberID != self.userID {
                        print(memberID)
                    }
                }
            }
        }
    }
    
    
    func getData(at indexPath:IndexPath) -> [String:AnyObject]{
        return data[indexPath.row]
    }
    
    func changePrivacy(isPrivate:Bool){
        switch isPrivate {
        case true:
            self.data[2] = ["title":"Public",
                            "image":UIImage(named: "public_icon")!,
                "description":"This workout is public. This means that it can be viewed by everyone and it may appear on the discover page. Tap to change."] as [String:AnyObject]
        case false:
            self.data[2] = ["title":"Private",
                            "image":UIImage(named: "locked_icon")!,
                            "description":"This workout is private. This means it can only be viewed by your followers and players/coaches. Tap to Change."] as [String:AnyObject]
        }

    }
    
    func changeSaved(isSaved:Bool){
        switch isSaved {
        case true:
            self.data[3] = ["title":"Add to Saved",
                            "image":UIImage(named: "Workout UnCompleted")!,
                            "description":"Not adding this workout to your saved workouts. You won't be able to add this workout in the future. Tap to change."] as [String:AnyObject]
        case false:
            self.data[3] = ["title":"Add to Saved",
                            "image":UIImage(named: "Workout Completed")!,
                            "description":"Adding this workout to your saved workouts where you can add it to your workouts in the future. Tap to change."] as [String:AnyObject]

        }
    }
    
    func changeCreated(isCreated:Bool){
        switch isCreated {
        case true:
            self.data[4] = ["title":"Add to Created",
                            "image":UIImage(named: "Workout UnCompleted")!,
                            "description":"Not adding this workout to your created workout list. Your created workout list lets other users see the kind of workouts you create. We recommend adding all your workouts to your created workout list.Tap to Change."] as [String:AnyObject]
        case false:
            self.data[4] = ["title":"Add to Created",
                            "image":UIImage(named: "Workout Completed")!,
                            "description":"Adding this workout to your created workout list. Your created workout list lets other users see the kind of workouts you create. We recommend adding all your workouts to your created workout list.Tap to Change."] as [String:AnyObject]
        }
    }
    
    func changePosting(isPosting:Bool){
        switch isPosting {
        case true:
            self.data[5] = ["title":"Post to Timeline",
                            "image":UIImage(named: "Workout UnCompleted")!,
                            "description":"Not posting this workout to the timeline. Tap to change."] as [String:AnyObject]
        case false:
            self.data[5] = ["title":"Post to Timeline",
                            "image":UIImage(named: "Workout Completed")!,
                            "description":"Posting this workout to the timeline. Your followers and players/coaches will be able to see this workout on the timeline. Tap to change."] as [String:AnyObject]

        }
    }
}
