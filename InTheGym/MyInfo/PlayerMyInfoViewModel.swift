//
//  PlayerMyInfoViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PlayerMyInfoViewModel {

    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadCollectionViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    
    
    // MARK: - Properties
    
    
    // The collection that will contain our fetched data
    private var myInfoData: [[String:AnyObject]] = [] {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        return myInfoData.count
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    
    
    // MARK: - Fetching functions
    
    func fetchData() {
        self.isLoading = true
        
        
        let data = [
                    ["title": "My Profile",
                     "image": UIImage(named: "coach_icon")!,
                     "description": "View your profile. See all your posts and followers, edit your profile and access more profile info like coaches, requests and workload."],
                    ["title": "Workout Scores",
                     "image": UIImage(named: "scores_icon")!,
                     "description": "View your workout scores. See the scores from all of the workouts you have completed / created."],
                    ["title": "Saved Workouts",
                     "image": UIImage(named: "benchpress_icon")!,
                     "description": "View your saved workouts. See all of the workouts you have saved and view all the data including average rpe and average time."],
                    ["title": "Created Workouts",
                     "image": UIImage(named: "hammer_icon")!,
                     "description": "View all of the workouts you have created. All the workouts you created are stored in here."],
                    ["title": "Notifications",
                     "image": UIImage(named: "bell_icon")!,
                     "description":"View your notifications. Notifications include when another user likes or replies to one of your posts or when another user follows you."]
                    ] as [[String:AnyObject]]
        
        self.myInfoData = data
        self.isLoading = false
        
    }
    
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> [String:AnyObject] {
        return myInfoData[indexPath.section]
    }

    
    
}
