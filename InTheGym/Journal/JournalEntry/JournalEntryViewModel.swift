//
//  JournalEntryViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import FirebaseFirestore
import Foundation

class JournalEntryViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var canUpload: Bool = false
    @Published var entryText: String = ""
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    func initSubscriptions() {
        $entryText
            .map { $0.trimTrailingWhiteSpaces().count > 3 }
            .sink { [weak self] in self?.canUpload = $0 }
            .store(in: &subscriptions)
    }
    
    @MainActor
    func uploadNewEntry() async throws -> JournalEntryModel {
        isUploading = true
        let newEntry = JournalEntryModel(date: .now, entry: entryText.trimTrailingWhiteSpaces())
        let docRef = Firestore.firestore().collection("Journal").document(UserDefaults.currentUser.uid).collection("Entries").document()
        let currentDocRef = Firestore.firestore().collection("Journal").document(UserDefaults.currentUser.uid)
        let batch = Firestore.firestore().batch()
        
        try batch.setData(from: newEntry, forDocument: docRef)
        try batch.setData(from: newEntry, forDocument: currentDocRef)
        try await batch.commit()
        isUploading = false
        uploaded = true
        return newEntry
    }

}
