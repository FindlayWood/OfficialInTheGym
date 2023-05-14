//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Combine
import Foundation

class ClubsViewModel: ObservableObject {
    
    var coordinator: ClubsFlow?
    
    var clubManager: ClubManager
    
    var hasLoaded: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var clubs: [RemoteClubModel] = []
    
    var filteredResults: [RemoteClubModel] {
        if searchText.isEmpty {
            return clubs
        } else {
            return clubs.filter { ($0.clubName.lowercased().contains(searchText.lowercased())) }
        }
    }
    
    // MARK: - Initializer
    init(clubManager: ClubManager, flow: ClubsFlow?) {
        self.clubManager = clubManager
        self.coordinator = flow
    }
    
    // MARK: - Load
    @MainActor
    func loadClubs() async {
        if !hasLoaded {
            isLoading = true
            do {
                try await clubManager.loadClubs()
                clubs = clubManager.clubs
                clubListener()
                isLoading = false
                hasLoaded = true
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    
    // MARK: - Listener
    func clubListener() {
        clubManager.clubsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.clubs = $0 }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    func addAction() {
//        coordinator?.addNewWorkout()
    }
    
    func showClubAction(_ model: RemoteClubModel) {
        coordinator?.goToClub(model)
    }
}
