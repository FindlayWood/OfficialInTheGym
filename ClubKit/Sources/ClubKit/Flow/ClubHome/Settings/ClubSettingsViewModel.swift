//
//  ClubSettingsViewModel.swift
//
//
//  Created by Findlay Wood on 07/02/2024.
//

import Foundation

class ClubSettingsViewModel: ObservableObject {
    
    @Published var isLoadingDelete: Bool = false
    @Published var errorDeleteing: Bool = false
    
    let clubModel: RemoteClubModel
    let imageCache: ImageCache
    let deletionService: DeleteClubService
    let clubManager: ClubManager
    
    var successfulDelete: (() -> ())?
    
    init(clubModel: RemoteClubModel, imageCache: ImageCache, deletionService: DeleteClubService, clubManager: ClubManager) {
        self.clubModel = clubModel
        self.imageCache = imageCache
        self.deletionService = deletionService
        self.clubManager = clubManager
    }
    
    
    func deleteClub() {
        isLoadingDelete = true
        let deleteData = DeleteClubData(id: clubModel.id, linkedUserUIDs: clubModel.linkedUserUIDs)
        Task {
            let result = await deletionService.deleteClub(with: deleteData)
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.clubManager.deleteClub(self.clubModel)
                    self.successfulDelete?()
                    self.isLoadingDelete = false
                }
            case .failure(let error):
                print(String(describing: error))
                DispatchQueue.main.async {
                    self.isLoadingDelete = false
                    self.errorDeleteing = true
                }
            }
        }
    }
}
