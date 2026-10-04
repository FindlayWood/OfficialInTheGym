//
//  FollowerRemover.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Removes someone from the signed-in user's followers by deleting *their*
/// follow document, which the rules allow the followee to do. The removed user
/// is not told. They could follow again unless blocked (step 9).
public protocol FollowerRemover {
    func removeFollower(_ userId: String) async throws
}
