//
//  NotificationManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class NotificationManager {
    
    var delegate: NotificationDelegate
    
    init(delegate: NotificationDelegate){
        self.delegate = delegate
    }
    
    func upload(){
        let notificationReference = Database.database().reference().child("Notifications").child(delegate.toUserID!).childByAutoId()
        notificationReference.setValue(delegate.toObject())
    }
    
}
