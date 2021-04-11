//
//  TimelineTapProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase


protocol TimelineTapProtocol {
    func likeButtonTapped(on cell:UITableViewCell, sender: UIButton, label:UILabel)
    func workoutTapped(on cell:UITableViewCell)
    func userTapped(on cell:UITableViewCell)
}

class checkFor{
    static func like(on post:String, completion:@escaping (Bool) -> ()){
        let userID = Auth.auth().currentUser!.uid
        let likeRef = Database.database().reference().child("Likes").child(userID).child(post)
        likeRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(true)
            }else{
                completion(false)
            }
        }
    }
}
