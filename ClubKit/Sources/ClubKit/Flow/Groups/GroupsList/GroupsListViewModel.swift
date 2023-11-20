//
//  File.swift
//  
//
//  Created by Findlay Wood on 19/11/2023.
//

import Foundation

class GroupsListViewModel: ObservableObject {
    
    @Published var errorLoading: Error?
    @Published var isLoading: Bool = false
    @Published var groups: [RemoteGroupModel] = []
    
    @Published var searchText: String = ""
    
    let groupLoader: GroupLoader
    let clubModel: RemoteClubModel
    
    var searchedGroups: [RemoteGroupModel] {
        if searchText.isEmpty {
            return groups
        } else {
            return groups.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init(groupLoader: GroupLoader, clubModel: RemoteClubModel) {
        self.groupLoader = groupLoader
        self.clubModel = clubModel
    }
    
    
    func load() {
        isLoading = true
        Task { @MainActor in
            do {
                groups = try await groupLoader.loadAllGroups(for: clubModel.id)
                isLoading = false
            } catch {
                errorLoading = error
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    func selectedGroupAction(_ model: RemoteGroupModel) {
        
    }
}
