//
//  CMJResultsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

class CMJResultsViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var loadingPower: Bool = false
    @Published var loadingFatigue: Bool = false
    @Published var measurements: JumpMeasurement = .cm
    @Published var height: Double = 0.0
    
    @Published var isSaving: Bool = false
    @Published var saveSucces: Bool = false
    // MARK: - Properties
    
    var averagePower: Double = 0
    var peakPower: Double = 0
    var fatigueLevel: CMJFatigueLevel = .green
    
    var jumpModel: CMJModel?
    var measurementsModel: MeasurementModel!
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
        var maxHeight = jumpModel?.maxHeight ?? 0
        var maxDate = jumpModel?.maxDate ?? .now
        let jumpNumber = jumpModel?.jumpNumber ?? 0
        if height > maxHeight {
            maxHeight = height
            maxDate = .now
        }
        let model = CMJModel(mostRecentData: .now,
                             jumpNumber: jumpNumber + 1,
                             peakPower: peakPower,
                             averagePower: averagePower,
                             fatigueLevel: fatigueLevel,
                             maxHeight: maxHeight,
                             maxDate: maxDate)
        
        let historyModel = CMJHistoyModel(date: .now,
                                          height: height,
                                          peakPower: peakPower,
                                          averagePower: averagePower,
                                          fatigueLevel: fatigueLevel)
        
        let modelRef = Firestore.firestore().collection("CMJ").document(UserDefaults.currentUser.uid)
        let historyRef = Firestore.firestore().collection("CMJ").document(UserDefaults.currentUser.uid).collection("Results").document()
        let batch = Firestore.firestore().batch()
        
        Task {
            do {
                try batch.setData(from: model, forDocument: modelRef)
                try batch.setData(from: historyModel, forDocument: historyRef)
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
    
    /// calculate the power output from the CMJ jump
    func calculatePower() {
        /// Johnson & Bahamonde Formula
        /// 1996
        loadingPower = true
        let athleteHeight = measurementsModel.height
        let athleteWeight = measurementsModel.weight
        let calculatedPeakPower = (78.6 * height) + (60.3 * athleteWeight) - (15.3 * athleteHeight) - 1308
        let calculatedAveragePower = (43.8 * height) + (32.7 * athleteWeight) - (16.8 * athleteHeight) + 431
        peakPower = calculatedPeakPower.rounded(toPlaces: 0)
        averagePower = calculatedAveragePower.rounded(toPlaces: 0)
        loadingPower = false
    }
    
    func calculateFatigue() {
        loadingFatigue = true
        if let jumpModel = jumpModel {
            if jumpModel.jumpNumber < 3 {
                fatigueLevel = .na
            } else {
                let percent = height / jumpModel.maxHeight
                if height > jumpModel.maxHeight {
                    fatigueLevel = .personalBest
                } else if percent > 0.949 {
                    fatigueLevel = .green
                } else if percent > 0.899 {
                    fatigueLevel = .yellow
                } else {
                    fatigueLevel = .red
                }
            }
        } else {
            fatigueLevel = .na
        }
        loadingFatigue = false
    }
    
    func convertToInches() {
        height = height.convertCMtoInches().rounded(toPlaces: 2)
    }
    func convertToCM() {
        height = height.convertInchestoCM().rounded(toPlaces: 2)
    }
}

enum JumpMeasurement: CaseIterable {
    case cm
    case inches
    
    var title: String {
        switch self {
        case .cm:
            return "cm"
        case .inches:
            return "in"
        }
    }
}

enum CMJFatigueLevel: String, Codable {
    case personalBest
    case green
    case yellow
    case red
    case na
    
    var title: String {
        switch self {
        case .personalBest:
            return "Personal Best"
        case .green:
            return "Good Score"
        case .yellow:
            return "Ok Score"
        case .red:
            return "Poor Score"
        case .na:
            return "Not enough Jumps"
        }
    }
    
    var message: String {
        switch self {
        case .personalBest:
            return "This is a personal best CMJ result. You are showing no signs of lower body fatigue."
        case .green:
            return "This is a good CMJ result, around your personal best. You are showing no signs of lower body fatigue."
        case .yellow:
            return "This is an ok CMJ result. It is a little below your personal best and you are showing signs that you may be experiencing some lower body fatigue."
        case .red:
            return "This is a poor CMJ result. This is wy below your personal best and you are showing clear signs of lower body fatigue. Consider takign a rest day or changing your training routine."
        case .na:
            return "You need to have completed at least 3 max effort CMJ to calculate fatigue levels."
        }
    }
}
