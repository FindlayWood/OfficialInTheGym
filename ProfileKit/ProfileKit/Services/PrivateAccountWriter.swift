//
//  PrivateAccountWriter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Sets the signed-in user's account private or public.
///
/// Going private changes only what **new** follows do (they become requests).
/// Existing followers stay. Going public approves every waiting request, which
/// the `approvePendingFollows` function does server-side. The screen says so
/// before the switch is made.
public protocol PrivateAccountWriter {
    func setPrivate(_ isPrivate: Bool) async throws
}
