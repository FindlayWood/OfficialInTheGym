//
//  File.swift
//  
//
//  Created by Findlay Wood on 10/12/2023.
//

import UIKit

class PlayerDetailViewModel: ObservableObject {
    
    @Published var teams: [RemoteTeamModel] = []
    @Published var groups: [RemoteGroupModel] = []
    
    @Published var isLoadingGroups: Bool = false
    @Published var isLoadingTeams: Bool = false
    
    @Published var isEditing: Bool = false
    
    let playerModel: RemotePlayerModel
    let clubModel: RemoteClubModel
    let groupLoader: GroupLoader
    let teamLoader: TeamLoader
    var imageCache: ImageCache
    let updateService: UpdatePlayerDetailService
    
    var linkActionCallback: (() -> ())?
    
    init(playerModel: RemotePlayerModel, clubModel: RemoteClubModel, groupLoader: GroupLoader, teamLoader: TeamLoader, imageCache: ImageCache, updateService: UpdatePlayerDetailService) {
        self.playerModel = playerModel
        self.clubModel = clubModel
        self.groupLoader = groupLoader
        self.teamLoader = teamLoader
        self.imageCache = imageCache
        self.updateService = updateService
        self.playerPositions = playerModel.positions
        self.newName = playerModel.displayName
    }
    
    func loadTeams() {
        isLoadingTeams = true
        Task { @MainActor in
            for teamID in playerModel.teams {
                let team = try await teamLoader.loadTeam(with: teamID, from: playerModel.clubID)
                teams.append(team)
            }
            isLoadingTeams = false
        }
    }
    
    func loadGroups() {
        isLoadingGroups = true
        Task {
            var groups: [RemoteGroupModel] = []
            for groupID in playerModel.groups {
                let group = try await groupLoader.loadGroup(with: groupID, from: playerModel.clubID)
                groups.append(group)
            }
            self.groups = groups
            isLoadingGroups = false
        }
    }
    
    // MARK: - Actions
    func linkAction() {
        linkActionCallback?()
    }
    
    // MARK: - Edit Vars
    @Published var playerPositions: [Positions] = []
    @Published var newName: String = ""
    @Published var libraryImage: UIImage?
    @Published var isSavingEdit: Bool = false
    
    // MARK: - Edit Functions
    func toggleSelectedPosition(_ position: Positions) {
        if let index = playerPositions.firstIndex(of: position) {
            playerPositions.remove(at: index)
        } else {
            playerPositions.append(position)
        }
    }
    
    func isPositionSelected(_ postion: Positions) -> Bool {
        playerPositions.contains(postion)
    }
    var isSaveButtonDisabled: Bool {
        playerPositions == playerModel.positions && newName == playerModel.displayName
    }
    
    func saveEdit() {
        isSavingEdit = true
        Task {
            let imageData = libraryImage?.jpegData(compressionQuality: 0.1)
            let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters)
            let updateData = UpdatePlayerData(playerID: playerModel.id, displayName: newName, clubID: clubModel.id, positions: playerPositions.map { $0.rawValue }, imageData: strBase64)
            let result = await updateService.updatePlayer(with: updateData)
            switch result {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isSavingEdit = false
                    self.isEditing = false
                }
            case .failure(let failure):
                print(String(describing: failure))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isSavingEdit = false
                    self.isEditing = false
                }
            }
        }
    }
}
