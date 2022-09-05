//
//  CMJHomeViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import SwiftUI

class CMJHomeViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var hasValidJumpNumber: Bool = true
    @Published private(set) var dismiss: Bool = false
    @Published private(set) var recentModel: CMJModel?
    @Published private(set) var measurementsModel: MeasurementModel?
    @Published private(set) var action: CMJHomeActions?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var recentJumpScore: Double = 0.0
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func dismissAction() {
        dismiss = true
    }
    
    // MARK: - Methods
    @MainActor
    func loadRecentResult() async {
        isLoading = true
        let docRef = Firestore.firestore().collection("CMJ").document(UserDefaults.currentUser.uid)
        
        do {
            recentModel = try await docRef.getDocument().data(as: CMJModel.self)
            withAnimation {
                isLoading = false
            }
//            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
    @MainActor
    func loadMeasurements() async {
        isLoading = true
        
        let ref = Firestore.firestore().collection("AthleteMeasurements").document(UserDefaults.currentUser.uid)
        
        do {
            measurementsModel = try await ref.getDocument(as: MeasurementModel.self)
            self.isLoading = false
        } catch {
//            self.error = .networkError
            self.isLoading = false
        }
    }
    
    func action(_ newAction: CMJHomeActions) {
        action = newAction
    }
}

enum CMJHomeActions {
    case recordNewJump
    case myJumps
    case myMeasurements
}

struct CMJModel: Codable {
    var mostRecentData: Date
    var jumpNumber: Int
    var peakPower: Double
    var averagePower: Double
    var fatigueLevel: CMJFatigueLevel
    var maxHeight: Double
    var maxDate: Date
}

struct CMJHistoyModel: Codable {
    var date: Date
    var height: Double
    var peakPower: Double
    var averagePower: Double
    var fatigueLevel: CMJFatigueLevel
}
