//
//  ClubSettingsViewModel.swift
//
//
//  Created by Findlay Wood on 07/02/2024.
//

import Foundation

class ClubSettingsViewModel: ObservableObject {
    
    @Published var isLoadingDelete: Bool = false
    
    let clubModel: RemoteClubModel
    let imageCache: ImageCache
    
    init(clubModel: RemoteClubModel, imageCache: ImageCache) {
        self.clubModel = clubModel
        self.imageCache = imageCache
    }
    
    
    func deleteClub() {
        isLoadingDelete = true
    }
}
