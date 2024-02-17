//
//  File.swift
//  
//
//  Created by Findlay Wood on 10/12/2023.
//

import Foundation

class PlayerDetailViewModel: ObservableObject {
    
    @Published var teams: [RemoteTeamModel] = []
    @Published var groups: [RemoteGroupModel] = []
    
    @Published var isLoadingGroups: Bool = false
    @Published var isLoadingTeams: Bool = false
    
    @Published var isEditing: Bool = false
    
    let playerModel: RemotePlayerModel
    let groupLoader: GroupLoader
    let teamLoader: TeamLoader
    var imageCache: ImageCache
    
    var linkActionCallback: (() -> ())?
    
    init(playerModel: RemotePlayerModel, groupLoader: GroupLoader, teamLoader: TeamLoader, imageCache: ImageCache) {
        self.playerModel = playerModel
        self.groupLoader = groupLoader
        self.teamLoader = teamLoader
        self.imageCache = imageCache
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
}
