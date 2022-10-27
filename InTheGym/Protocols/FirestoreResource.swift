//
//  FirestoreResource.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

protocol FirestoreResource: Codable {
    
    /// The string path to a collection in Firestore
    /// Must be static to allow access without creating an instance
    var collectionPath: String { get }
    
    /// The string that is the document ID of model
    /// Must be static to allow access without creating an instance
    var documentID: String { get }
}
