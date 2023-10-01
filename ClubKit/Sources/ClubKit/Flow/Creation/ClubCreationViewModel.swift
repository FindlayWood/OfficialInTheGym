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
    @Published var isPrivate: Bool = false
    
    var service: ClubCreationService
    var clubManager: ClubManager
    
    init(service: ClubCreationService, clubManager: ClubManager) {
        self.service = service
        self.clubManager = clubManager
    }
    
    func createAction() {
        let newData = NewClubData(displayName: displayName, tagline: tagline, sport: sport, isPrivate: isPrivate)
        Task {
            let result = await service.createNewClub(with: newData)
            switch result {
            case .success(let newClubData):
                mapClubDataToClubModel(newClubData)
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    
    func mapClubDataToClubModel(_ data: NewClubData) {
        let newClubModel = RemoteClubModel(id: data.id, clubName: data.displayName, tagline: data.tagline, createdBy: "", createdDate: .now, sport: data.sport, verified: false, teamCount: 0, athleteCount: 0)
        clubManager.createdNewClub(newClubModel)
    }
}
