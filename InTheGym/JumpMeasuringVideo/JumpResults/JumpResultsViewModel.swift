//
//  JumpResultsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class JumpResultsViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var loadingPower: Bool = false
    @Published var loadingFatigue: Bool = false
    @Published var measurements: JumpMeasurement = .cm
    @Published var height: Double = 0.0
    
    @Published var isSaving: Bool = false
    @Published var saveSucces: Bool = false
    @Published private(set) var dismiss = false
    
    // MARK: - Properties
    var maxModel: VerticalJumpModel?
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Methods
    @MainActor
    func saveResult() {
        withAnimation {
            isSaving = true
        }
        if measurements == .inches {
            convertToCM()
        }
        
        var maxHeight = maxModel?.height ?? 0
        var maxDate = maxModel?.time ?? .now
        if height > maxHeight {
            maxHeight = height
            maxDate = .now
        }

        let model = VerticalJumpModel(time: .now, height: height)
        let maxModel = VerticalJumpModel(time: maxDate, height: maxHeight)
        
        let maxModelRef = Firestore.firestore().collection("VerticalJump").document(UserDefaults.currentUser.uid)
        let verticalJumpRef = Firestore.firestore().collection("VerticalJump").document(UserDefaults.currentUser.uid).collection("Results").document()
        let batch = Firestore.firestore().batch()
        
        Task {
            do {
                try batch.setData(from: model, forDocument: verticalJumpRef)
                try batch.setData(from: maxModel, forDocument: maxModelRef)
                try await batch.commit()
                withAnimation {
                    saveSucces = true
                    isSaving = false
                }
            } catch {
                print(String(describing: error))
            }
        }

    }
    
    func convertToInches() {
        height = height.convertCMtoInches().rounded(toPlaces: 2)
    }
    func convertToCM() {
        height = height.convertInchestoCM().rounded(toPlaces: 2)
    }
    func dismissAction() {
        dismiss = true
    }
}
