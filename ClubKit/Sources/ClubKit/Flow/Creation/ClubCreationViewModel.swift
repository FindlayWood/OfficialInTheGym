//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

class ClubCreationViewModel: ObservableObject {
    
    @Published var displayName: String = ""
    @Published var tagline: String = ""
    @Published var sport: Sport = .rugby
    @Published var userRole: ClubRole = .manager
    @Published var selectedPositions: [Positions] = []
    @Published var isPrivate: Bool = false
    
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    
    var service: ClubCreationService
    var clubManager: ClubManager
    
    init(service: ClubCreationService, clubManager: ClubManager) {
        self.service = service
        self.clubManager = clubManager
    }
    
    func createAction() {
        isUploading = true
        if userRole == .manager {
            selectedPositions = []
        }
        let newData = NewClubData(displayName: displayName, tagline: tagline, sport: sport, isPrivate: isPrivate, currentUserRole: userRole, positions: selectedPositions)
        Task {
            let result = await service.createNewClub(with: newData)
            switch result {
            case .success(let newClubData):
                mapClubDataToClubModel(newClubData)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.displayName = ""
                    self.isUploading = false
                    self.uploaded = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.uploaded = false
                    }
                }
            case .failure(let error):
                print(String(describing: error))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isUploading = false
                    self.errorUploading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.errorUploading = false
                    }
                }
            }
        }
    }
    
    func updateSport(to newSport: Sport) {
        selectedPositions.removeAll()
        sport = newSport
    }
    
    func addSelectedPosition(_ position: Positions) {
        if !selectedPositions.contains(position) {
            selectedPositions.append(position)
        }
    }
    
    func mapClubDataToClubModel(_ data: NewClubData) {
        let newClubModel = RemoteClubModel(id: data.id, clubName: data.displayName, tagline: data.tagline, createdBy: "", createdDate: .now, sport: data.sport, verified: false, teamCount: 0, athleteCount: 0, linkedUserUIDs: [])
        clubManager.createdNewClub(newClubModel)
    }
    
    var buttonDisabled: Bool {
        displayName.isEmpty
    }
}
