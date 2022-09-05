//
//  PlayerDashBoardCollectionCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class PlayerDashBoardCollectionViewCellViewModel {
    // MARK: - Publishers
    @Published var imageData: Data?
    @Published var latestWorkloadModel: WorkloadModel?
    @Published var athleteTrainingStatus: AthleteStatus = .inSeason
    @Published var athleteWellnessStatus: WellnessStatus = .na
    @Published var athleteInjuryStatus: InjuryStatus = .fit
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var user: Users
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared, user: Users) {
        self.apiService = apiService
        self.user = user
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    func loadProfileImage() {
        DispatchQueue.global(qos: .background).async {
            let profileImageModel = ProfileImageDownloadModel(id: self.user.uid)
            ImageCache.shared.load(from: profileImageModel) { [weak self] result in
                let imageData = try? result.get().pngData()
                self?.imageData = imageData
            }
        }
    }
    
    func loadLastWorkout() {
        let workloadSearchModel = WorkloadSearchModel(id: user.uid)
        apiService.fetchLimitedInstance(of: workloadSearchModel, returning: WorkloadModel.self, limit: 1) { [weak self] result in
            let models = try? result.get()
            self?.latestWorkloadModel = models?.first
        }
    }
    
    func loadWellness() async {
        let docRef = Firestore.firestore().collection("WellnessScores").document(user.uid)
        if let wellnessModel = try? await docRef.getDocument().data(as: WellnessAnswersModel.self) {
            if Calendar.current.numberOfDaysBetween(.now, and: wellnessModel.time) < 4 {
                athleteWellnessStatus = wellnessModel.status
            } else {
                athleteWellnessStatus = .na
            }
        }
    }
    
    func loadTrainingStatus() async {
        let docRef = Firestore.firestore().collection("TrainingStatus").document(user.uid)
        if let trainingModel = try? await docRef.getDocument().data(as: TrainingStatusModel.self) {
            athleteTrainingStatus = trainingModel.status
        }
    }
    
    func loadInjuryStatus() async {
        let docRef = Firestore.firestore().collection("InjuryStatus").document(user.id)
        if let currentInjuryModel = try? await docRef.getDocument().data(as: InjuryModel.self) {
            if Calendar.current.numberOfDaysBetween(currentInjuryModel.dateOccured, and: .now) > 0 {
                athleteInjuryStatus = currentInjuryModel.status
            }
        }
    }
}
