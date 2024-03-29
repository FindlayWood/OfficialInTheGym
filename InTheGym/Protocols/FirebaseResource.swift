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
//typealias FirebaseKeyReturn = FirebaseModel & FirebaseID

//// MARK: - Firebase ID
///// A type that has an id/key that needs to be retreived from Firebase
///// When fetchingKeys function called the returning type must conform to FirebaseID
//protocol FirebaseID {
//    var id: String { get set }
//}

// MARK: - Time Orderd ID
/// A type that has an id that needs to be time ordered
/// The id will use Firebase's childByAutoID() function to create this id
protocol TimeOrderedID: Codable {
    var id: String { get set }
}

typealias FirebaseTimeOrderedModel = FirebaseInstance & TimeOrderedID

// MARK: - Firebase Instance Extension
extension FirebaseInstance {
    func toFirebaseJSON() -> FirebaseMultiUploadDataPoint? {
        do {
            let data = try JSONEncoder().encode(self)
            let firebaseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return FirebaseMultiUploadDataPoint(value: firebaseJSON, path: self.internalPath)
        }
        catch {
            return nil
        }
    }
}


// MARK: - Firebase Query Model
/// A type that has a query to search in the Firebase Database
/// It has an orderdedByChild string value and an equalTo string value
/// This type also requires Firebase Instance to have an internal path
protocol FirebaseQueryModel: FirebaseInstance {
    
    /// The string value to order the query by
    var orderedBy: String { get }
    
    /// The string value to search in the query
    var equalTo: String { get }
}

// MARK: - Firebase String Search Model
/// A type that has a string query to search
/// It has an orderedByChild string value - the path to query
/// This type requires Firebase Instance to have internal path
protocol FirebaseStringSearchModel: FirebaseInstance {
    
    /// The string value tp order the query by
    var orderedBy: String { get }
    
    /// The String value to search in the query
    var equalTo: String { get }
}
