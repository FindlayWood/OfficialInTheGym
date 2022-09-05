//
//  TrainingStatusViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TrainingStatusViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var currentStatus: AthleteStatus = .inSeason
    @Published var previousChanges: [TrainingStatusModel] = []
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Methods
    @MainActor
    func loadModels() async {
        isLoading = true
        let bdref = Firestore.firestore().collection("TrainingStatus/\(UserDefaults.currentUser.uid)/statusUpdates")
        
        do {
            let snapshots = try await bdref.getDocuments()
            let dataModels = try snapshots.documents.map { try $0.data(as: TrainingStatusModel.self) }
            previousChanges = dataModels.sorted()
            currentStatus = previousChanges.first?.status ?? .inSeason
            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
    
    func changeStatus(_ newStatus: AthleteStatus) {
        let model = TrainingStatusModel(status: newStatus, time: Date())
        let uid = UserDefaults.currentUser.uid
        
        let ref = Firestore.firestore().collection("TrainingStatus").document(uid)
        let bdref = Firestore.firestore().collection("TrainingStatus/\(uid)/statusUpdates").document()
        
        do {
            try ref.setData(from: model)
            try bdref.setData(from: model)
            previousChanges.append(model)
            previousChanges = previousChanges.sorted()
        } catch {
            print(String(describing: error))
        }
    }
}


struct TrainingStatusModel: Identifiable, Codable, Comparable {
    static func < (lhs: TrainingStatusModel, rhs: TrainingStatusModel) -> Bool {
        lhs.time > rhs.time
    }
    
    @DocumentID var docID: String?
    var status: AthleteStatus
    var time: Date
    
    var id: String {
        docID ?? UUID().uuidString
    }
    
    
}
