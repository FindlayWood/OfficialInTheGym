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
        self.originalPositions = playerModel.positions
        self.playerPositions = playerModel.positions
        self.newName = playerModel.displayName
        self.selectedTeams = playerModel.teams
        self.originalPlayerTeams = playerModel.teams
    }
    
    func loadTeams() {
        isLoadingTeams = true
        Task { @MainActor in
            teams = try await teamLoader.loadAllTeams(for: clubModel.id)
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
    let originalPositions: [Positions]
    @Published var playerPositions: [Positions] = []
    let originalPlayerTeams: [String]
    @Published var selectedTeams: [String] = []
    @Published var removedFromTeams: [String] = []
    @Published var addedToTeams: [String] = []
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
    
    func toggleSelectedTeam(_ model: RemoteTeamModel) {
        if let index = selectedTeams.firstIndex(where: { $0 == model.id }) {
            selectedTeams.remove(at: index)
            if originalPlayerTeams.contains(model.id) {
                removedFromTeams.append(model.id)
            } else {
                selectedTeams.removeAll(where: { $0 == model.id })
                addedToTeams.removeAll(where: { $0 == model.id })
            }
        } else {
            selectedTeams.append(model.id)
            if originalPlayerTeams.contains(model.id) {
                removedFromTeams.removeAll(where: { $0 == model.id })
            } else {
                selectedTeams.append(model.id)
                addedToTeams.append(model.id)
            }
        }
    }
    
    func isTeamSelected(_ id: String) -> Bool {
        selectedTeams.contains(id)
    }
    var isSaveButtonDisabled: Bool {
        playerPositions == playerModel.positions && newName == playerModel.displayName && selectedTeams == originalPlayerTeams && removedFromTeams.isEmpty
    }
    
    func saveEdit() {
        isSavingEdit = true
        Task {
            let imageData = libraryImage?.jpegData(compressionQuality: 0.1)
            let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters)
            let addedTeams = addedToTeams.isEmpty ? nil : addedToTeams
            let removedTeams = removedFromTeams.isEmpty ? nil : removedFromTeams
            let updateData = UpdatePlayerData(playerID: playerModel.id, displayName: newName, clubID: clubModel.id, positions: playerPositions.map { $0.rawValue }, imageData: strBase64, addedToTeams: addedTeams, removedFromTeams: removedTeams)
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
    
    func cancelEdit() {
        selectedTeams = originalPlayerTeams
        removedFromTeams.removeAll()
        playerPositions = originalPositions
    }
}
