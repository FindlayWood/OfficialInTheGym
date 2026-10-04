//
//  FunctionsAccountDeleter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// Calls the `deleteAccount` Cloud Function, which removes the user's data
/// from Firestore, Storage and the Realtime Database, then the Auth user
/// (`PROFILE_PLAN.md` step 10). Through `FunctionsManager`, so emulator builds
/// reach the emulator.
struct FunctionsAccountDeleter {

    var functionsService: FunctionsManager = FirebaseFunctionsManager()

    func deleteRemoteAccount() async throws {
        try await functionsService.callable(named: "deleteAccount", data: [String: Any]())
    }
}
