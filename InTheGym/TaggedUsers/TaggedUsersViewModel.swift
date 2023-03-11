//
//  TaggedUsersViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 11/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

class TaggedUsersViewModel: ObservableObject {
    
    @Published var taggedUsers: [Users] = []
    @Published var isLoading: Bool = false
    var ids: [String] = []
    
    func loadUsers() {
        isLoading = true
        for id in ids {
            let userSearchModel = UserSearchModel(uid: id)
            UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
                guard let user = try? result.get() else {return}
                self?.taggedUsers.append(user)
            }
        }
        isLoading = false
    }
}
