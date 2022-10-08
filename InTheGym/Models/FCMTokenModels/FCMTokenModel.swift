//
//  FCMTokenModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift
/// this model is used to register this device with notifications
struct FCMTokenModel {
    @ExplicitNull var fcmToken: String?
    var tokenUpdatedDate: Date
}
extension FCMTokenModel: FirestoreResource {
    var collectionPath: String {
        "FCMTokens"
    }
    
    var documentID: String {
        UserDefaults.currentUser.uid
    }
}
