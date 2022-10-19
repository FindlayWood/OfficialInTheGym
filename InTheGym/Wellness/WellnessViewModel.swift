//
//  WellnessViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class WellnessViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var isLoading: Bool = false
    @Published var isShowingQuestionaireSheet: Bool = false
    @Published var currentScore: WellnessAnswersModel?
    @Published var previousScores: [WellnessAnswersModel] = []
    // MARK: - Properties
    
    // MARK: - Methods
    @MainActor
    func getWellnessScores() async {
        isLoading = true
        let dbref = Firestore.firestore().collection("WellnessScores").document(UserDefaults.currentUser.uid).collection("scores").order(by: "time", descending: true)
        do {
            let snapshots = try await dbref.getDocuments()
            let data = try snapshots.documents.map { try $0.data(as: WellnessAnswersModel.self) }
            guard let first = data.first else {
                isLoading = false
                return
            }
            let calendar = NSCalendar.current
            if calendar.isDateInToday(first.time) {
                currentScore = first
            }
            previousScores = data
            data.forEach { dat in
                print(dat.time)
            }
            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
    
    @MainActor
    func generatedCurrentScore(from model: WellnessAnswersModel) async {
        let batch = Firestore.firestore().batch()
        let docRef = Firestore.firestore().collection("WellnessScores").document(UserDefaults.currentUser.uid)
        let historyRef = Firestore.firestore().collection("WellnessScores").document(UserDefaults.currentUser.uid).collection("scores").document()
        do {
            try batch.setData(from: model, forDocument: docRef)
            try batch.setData(from: model, forDocument: historyRef)
            try await batch.commit()
            currentScore = model
            previousScores.append(model)
        } catch {
            print(String(describing: error))
        }
    }
}

struct WellnessScoreModel: Codable, Identifiable {
    @DocumentID var docID: String?
    var score: Int
    var time: Date
    
    var id: String {
        docID ?? UUID().uuidString
    }
}

struct WellnessAnswersModel: Codable, Identifiable {
//    @DocumentID var docID: String?
    
    var time: Date
    var sleepAmount: Double
    var sleepQuality: Int
    var bodyFeeling: Int
    var mindFeeling: Int
    var happyFeeling: Int
    var motivationFeeling: Int
    var status: WellnessStatus
    
    var id: String {
        time.description
    }
}
