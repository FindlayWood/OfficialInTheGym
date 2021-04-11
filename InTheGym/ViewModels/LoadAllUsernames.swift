//
//  LoadAllUsernames.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/02/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class loadUsernamesViewModel:NSObject{
    // class to load all usernames
    
    
    private var DBRef : DatabaseReference!
    private var tempUsernameArray : [String] = [String]()
    private(set) var allUsernames : [String]! {
        didSet{
            self.bindAllUsernamesToController()
        }
    }
    
    var bindAllUsernamesToController : (() -> ()) = {}
    
    override init() {
        super.init()
        self.DBRef = Database.database().reference().child("Usernames")
        loadAllUsername()
    }
    
    func loadAllUsername(){
        self.DBRef.observe(.value) { (snapshot) in
            if let snap = snapshot.value as? [String]{
                self.allUsernames = snap
            }
        }
    }
    
    
    
    
}
