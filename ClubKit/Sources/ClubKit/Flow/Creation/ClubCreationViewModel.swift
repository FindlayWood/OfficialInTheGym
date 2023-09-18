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
    
    var service: CreationService
    
    init(service: CreationService) {
        self.service = service
    }
    
    func createAction() {
        let newData = NewClubData(displayName: displayName, tagline: tagline, sport: sport, isPrivate: isPrivate)
        Task {
            let result = await service.createNewClub(with: newData)
            switch result {
            case .success(let success):
                break
            case .failure(let failure):
                break
            }
        }
    }
}
