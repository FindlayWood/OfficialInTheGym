//
//  FollowRequestApprover.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Approves someone's request to follow the signed-in user, turning their
/// pending follow active. Declining needs no protocol of its own: it is
/// `FollowerRemover`, the same delete of their follow document.
public protocol FollowRequestApprover {
    func approve(_ userId: String) async throws
}
