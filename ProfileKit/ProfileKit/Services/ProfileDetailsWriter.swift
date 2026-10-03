//
//  ProfileDetailsWriter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Saves the signed-in user's display name and bio.
///
/// The app writes Firestore `Users/{uid}` and nothing else remote. The
/// `onEditAccount` Cloud Function mirrors the edit into the legacy RTDB
/// `users/{uid}`, and `syncProfile` into the public `Profiles/{uid}`, so the
/// client writes one remote destination however many stores read the result.
public protocol ProfileDetailsWriter {
    func save(_ details: ProfileDetails) async throws
}
