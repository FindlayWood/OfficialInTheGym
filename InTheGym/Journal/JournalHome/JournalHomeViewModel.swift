//
//  JournalHomeViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation

class JournalHomeViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var isLoading: Bool = false
    @Published var isShowingNewEntrySheet = false
    @Published private(set) var hasEnteredToday: Bool = false
    @Published var journalEntries: [JournalEntryModel] = []
    @Published private(set) var todayEntry: JournalEntryModel?
    // MARK: - Properties
    
    // MARK: - Methods
    @MainActor
    func getJournalEntries() async {
        isLoading = true
        let dbref = Firestore.firestore().collection("Journal").document(UserDefaults.currentUser.uid).collection("Entries").order(by: "date", descending: true)
        let mostRecentEntryRef = Firestore.firestore().collection("Journal").document(UserDefaults.currentUser.uid)
        do {
            let snapshots = try await dbref.getDocuments()
            let data = try snapshots.documents.map { try $0.data(as: JournalEntryModel.self) }
            journalEntries = data
            let mostRecentEntry = try await mostRecentEntryRef.getDocument().data(as: JournalEntryModel.self)
            let calendar = NSCalendar.current
            if calendar.isDateInToday(mostRecentEntry.date) {
                hasEnteredToday = true
            }
            todayEntry = mostRecentEntry
            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
}

struct JournalEntryModel: Codable, Identifiable {
    var date: Date
    var entry: String
    
    var id: String {
        UUID().uuidString
    }
}
