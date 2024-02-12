//
//  ClubSettingsViewModel.swift
//
//
//  Created by Findlay Wood on 07/02/2024.
//

import Foundation

class ClubSettingsViewModel: ObservableObject {
    
    let clubModel: RemoteClubModel
    let imageCache: ImageCache
    
    init(clubModel: RemoteClubModel, imageCache: ImageCache) {
        self.clubModel = clubModel
        self.imageCache = imageCache
    }
}
