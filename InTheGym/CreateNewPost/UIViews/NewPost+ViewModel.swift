//
//  NewPost+ViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 27/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class NewPostViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var text: String = ""
    @Published var placeholder: String = "enter text..."
    @Published var attachedWorkout: SavedWorkoutModel?
    @Published var taggedUsers: [Users] = []
    @Published var isPrivate: Bool = false
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
}
 
