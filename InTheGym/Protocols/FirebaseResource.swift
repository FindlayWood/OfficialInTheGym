//
//  FirebaseResource.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

/// A type that can be loaded and uploaded to and from Firebase
/// A Firebase Resource REQUIRES Codable
//protocol FirebaseResource: Codable {
//
//    /// The String that holds the path to the correct database reference in Firebase
//    /// Must be static to allow access without creating instance
//    static var path: String { get }
//
//    /// The path to an instance of the model
//    /// This will usually include an id to point to specific database reference or specific list
//    var internalPath: String { get }
//}



// MARK: - Firebase Resource
/// one protocol for needed internal path and one protocol that requires first protocol and adds static path

/// A type that can be loaded and uploaded to Firebase
/// Instance refers to a specific path - requiring data from the model itself before searching at the path
/// Model refers to a model type - this does not refer to a specific instance of the model just the type itself hence the static path
/// If a model type needs access to a list of instances then it should conform to FirebaseModel otherwise FirebaseInstance will suffice
/// FirebaseModel conforms to FirebaseInstance meaning an internal Path is always needed for a Firebase Model
/// A FirebaseResource REQUIRES Codable
///
/// If a path requires the current users' ID then it should conform to FirebaseModel and use the AuthManager to acces the CurrentlyLoggedInUserID
/// 
protocol FirebaseInstance: Codable {
    
    /// The string path to an instance of a model
    /// Requires data from the model itself
    var internalPath: String { get }
}
protocol FirebaseModel: Codable {
    
    /// The string path to a reference in Firebase
    /// Must be static to allow access without creating an instance
    static var path: String { get }
}


typealias FirebaseResource = FirebaseInstance & FirebaseModel
typealias FirebaseKeyReturn = FirebaseModel & FirebaseID

// MARK: - Firebase ID
/// A type that has an id/key that needs to be retreived from Firebase
/// When fetchingKeys function called the returning type must conform to FirebaseID
protocol FirebaseID {
    var id: String { get set }
}
