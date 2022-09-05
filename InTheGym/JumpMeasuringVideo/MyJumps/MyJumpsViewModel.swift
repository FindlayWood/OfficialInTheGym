//
//  MyJumpsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation

class MyJumpsViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isLoading = false
    @Published var maxModel: VerticalJumpModel?
    @Published private(set) var action: VerticalJumpHomeViewActions?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    @MainActor
    func loadMaxJump() async {
        isLoading = true
        
        let ref = Firestore.firestore().collection("VerticalJump").document(UserDefaults.currentUser.uid)
        
        do {
            maxModel = try await ref.getDocument(as: VerticalJumpModel.self)
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }
    
    func action(_ action: VerticalJumpHomeViewActions) {
        self.action = action
    }
}

enum VerticalJumpHomeViewActions {
    case recordNewJump
    case previousJumps
    case help
}
