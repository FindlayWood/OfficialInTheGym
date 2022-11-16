//
//  InjuryTrackerViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation


class InjuryTrackerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var currentInjury: InjuryModel?
    @Published var previousInjuries: [InjuryModel] = []
    
    @Published var uploading = false
    @Published var uploaded = false
    @Published var description: String = ""
    @Published var placeholder: String = "enter description..."
    
    // MARK: - Methods
    @MainActor
    func loadModels() async {
        isLoading = true
        let bdref = Firestore.firestore().collection("InjuryStatus").document(UserDefaults.currentUser.uid).collection("statusUpdates")
        let currentRef = Firestore.firestore().collection("InjuryStatus").document(UserDefaults.currentUser.uid)
        
        do {
            currentInjury = try await currentRef.getDocument().data(as: InjuryModel.self)
            let snapshots = try await bdref.getDocuments()
            let dataModels = try snapshots.documents.map { try $0.data(as: InjuryModel.self) }
            previousInjuries = dataModels.sorted()
            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
    
    @Published var bodyPart: String = ""
    @Published var recoveryTime: Int = 7
    @Published var recoveryTimeOptions: RecoveryTimeOptions = .days
    @Published var sendNotification = true
    @Published var severity: InjurySeverity = .moderate
    
    @MainActor
    func addNewInjury() {
        uploading = true
        var status: InjuryStatus = .injured
        if severity == .light {
            status = .minorInjury
        }
        let newModel = InjuryModel(id: UUID().uuidString,
                                   dateOccured: .now,
                                   recoveryTime: getRecoveryDays(recoveryTime, recoveryTimeOptions),
                                   recovered: false,
                                   bodyPart: bodyPart,
                                   description: description,
                                   severity: severity,
                                   status: status)
        let docRef = Firestore.firestore().collection("InjuryStatus").document(UserDefaults.currentUser.uid)
        let historyRef = Firestore.firestore().collection("InjuryStatus/\(UserDefaults.currentUser.uid)/statusUpdates").document(newModel.id)
        do {
            try docRef.setData(from: newModel)
            try historyRef.setData(from: newModel)
            previousInjuries.append(newModel)
            currentInjury = newModel
            uploading = false
        } catch {
            print(String(describing: error))
            uploading = false
        }
    }
    
    func getRecoveryDays(_ recoveryTime: Int, _ option: RecoveryTimeOptions) -> Int {
        switch option {
        case .days:
            return recoveryTime
        case .weeks:
            return recoveryTime * 7
        case .months:
            return recoveryTime * 30
        }
    }
    
    func markInjuryAsRecovered(_ model: InjuryModel) async {
        let docRef = Firestore.firestore().collection("InjuryStatus").document(UserDefaults.currentUser.uid)
        
        do {
            if currentInjury?.id == model.id {
                try await docRef.updateData(["recovered": true, "status": "fit"])
            }
            let detailDocRef = Firestore.firestore().collection("InjuryStatus").document(UserDefaults.currentUser.uid).collection("statusUpdates").document(model.id)
            try await detailDocRef.updateData(["recovered": true])
        } catch {
            print(String(describing: error))
        }
    }
}


struct InjuryModel: Identifiable, Codable, Comparable {
    var id: String
    var dateOccured: Date
    var recoveryTime: Int /// days
    var recovered: Bool
    var bodyPart: String
    var description: String
    var severity: InjurySeverity
    var status: InjuryStatus
    
    static func < (lhs: InjuryModel, rhs: InjuryModel) -> Bool {
        lhs.dateOccured > rhs.dateOccured
    }
}

enum InjurySeverity: String, Codable, CaseIterable {
    case light
    case moderate
    case severe
    
    var title: String {
        switch self {
        case .light:
            return "Light"
        case .moderate:
            return "Moderate"
        case .severe:
            return "Severe"
        }
    }
}
