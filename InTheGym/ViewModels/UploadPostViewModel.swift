//
//  UploadPostViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//
// class to upload post data to firebase
// uploads to self and group if required

import Foundation
import UIKit
import Firebase

class UploadPost:NSObject{
    
    private var userID : String!
    private var groupToUpload : [String] = [String]()
    private var isGroup : Bool = false
    private var postData : [String:AnyObject] = [String:AnyObject]()
    private(set) var didUploadPost : Bool!{
        didSet{
            self.bindUploadPostToController()
        }
    }
    var bindUploadPostToController : (() -> ()) = {}
    
    init(postData:[String:AnyObject], selfID:String){
        self.postData = postData
        self.userID = selfID
        super.init()
        upload()
    }
    
    init(postData:[String:AnyObject], selfID:String, groupToUpload:[String]) {
        self.postData = postData
        self.userID = selfID
        self.groupToUpload = groupToUpload
        super.init()
        self.isGroup = true
        upload()
    }
    
    func upload(){
        let PostRef = Database.database().reference().child("Posts").child(userID).childByAutoId()
        let postKey = PostRef.key
        
        let timelineRef = Database.database().reference().child("Timeline")
        let timelineData = ["postID": postKey,
                            "posterID":userID]
        PostRef.setValue(self.postData)
        timelineRef.child(userID).childByAutoId().setValue(timelineData)
        
        if isGroup{
            for person in groupToUpload{
                timelineRef.child(person).childByAutoId().setValue(timelineData)
            }
        }
        
    }
    
    
    
}
