//
//  PreviousJumps+ViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 31/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension PreviousJumpsView {
    
    final class ViewModel: ObservableObject {
        // MARK: - Published Properties
        @Published private(set) var isLoading = false
        @Published private(set) var jumpModels: [VerticalJumpModel] = []
        @Published private(set) var sortedByDate = true
        @Published var measurement: JumpMeasurement = .cm
        
        // MARK: - Properties
        var sortedModels: [VerticalJumpModel] {
            if sortedByDate {
                return jumpModels.sorted(by: { $0.time > $1.time })
            } else {
                return jumpModels.sorted(by: {$0.height > $1.height })
            }
        }
        
        // MARK: - Methods
        @MainActor
        func loadModels() async {
            isLoading = true
            let docRef = Firestore.firestore().collection("VerticalJump").document(UserDefaults.currentUser.uid).collection("Results")
            do {
                let snapshot = try await docRef.getDocuments()
                let models = snapshot.documents.compactMap { try? $0.data(as: VerticalJumpModel.self) }
                jumpModels = models.sorted(by: { $0.time > $1.time })
                isLoading = false
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
        
        func sortedByDate(_ value: Bool) {
            sortedByDate = value
        }
    }
}
