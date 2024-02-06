//
//  File.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import Foundation

class CreateGroupViewModel: ObservableObject {
    
    @Published var groupName: String = ""
    
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    @Published var selectedPlayersList: [RemotePlayerModel] = []
    
    var selectedPlayers: (() -> ())?
    
    var buttonDisabled: Bool {
        groupName.isEmpty || selectedPlayersList.isEmpty
    }
    
    let clubModel: RemoteClubModel
    let creationService: GroupCreationService
    let imageCache: ImageCache
    
    init(clubModel: RemoteClubModel, creationService: GroupCreationService, imageCache: ImageCache) {
        self.clubModel = clubModel
        self.creationService = creationService
        self.imageCache = imageCache
    }
    
    func create() {
        isUploading = true
        let newGroupData = NewGroupData(displayName: groupName, clubID: clubModel.id, groupName: groupName, members: selectedPlayersList.map { $0.id })
        Task {
            let result = await creationService.createNewGroup(with: newGroupData)
            switch result {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.groupName = ""
                    self.selectedPlayersList.removeAll()
                    self.isUploading = false
                    self.uploaded = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.uploaded = false
                    }
                }
            case .failure(let failure):
                print(String(describing: failure))
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
    
    func addPlayers(_ players: [RemotePlayerModel]) {
        selectedPlayersList = players
    }
}
