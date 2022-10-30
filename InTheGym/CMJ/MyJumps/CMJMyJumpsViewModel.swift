//
//  CMJMyJumpsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension CMJMyJumpsView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        // MARK: - Published Properties
        @Published var isLoading: Bool = false
        @Published var jumpModels: [CMJHistoyModel] = []
        
        // MARK: - Methods
        func loadModels() async {
            isLoading = true
            let docRef = Firestore.firestore().collection("CMJ").document(UserDefaults.currentUser.uid).collection("Results")
            do {
                let snapshot = try await docRef.getDocuments()
                let models = snapshot.documents.compactMap { try? $0.data(as: CMJHistoyModel.self) }
                jumpModels = models.sorted(by: { $0.date > $1.date })
                isLoading = false
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
    }
}
