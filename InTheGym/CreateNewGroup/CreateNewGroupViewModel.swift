//
//  CreateNewGroupViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CreateNewGroupViewModel {
    
    // MARK: - Publishers
    @Published var selectedUsers: [Users] = []
    @Published var groupTitle: String = ""
    @Published private var validTitle: Bool = false
    @Published private var validMembers: Bool = false
    @Published var canCreate: Bool = false
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: FirebaseDatabaseManagerService
  
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    // MARK: - Actions
    func createNewGroup() {
        let newGroup = GroupModel(uid: UUID().uuidString,
                                  description: "",
                                  leader: UserDefaults.currentUser.uid,
                                  title: groupTitle,
                                  username: groupTitle)
        guard let uploadPoint = newGroup.toFirebaseJSON() else {return}
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        uploadPoints.append(uploadPoint)
        uploadPoints.append(contentsOf: getPlayerUploadPoints(newGroup.uid))
        uploadPoints.append(getLeaderReference(newGroup.uid))
        uploadPoints.append(contentsOf: getGroupMembers(newGroup.uid))
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                print("hoooraaay!")
            case .failure(_):
                print("noooooooo")
            }
        }
    }

    
    // MARK: - Functions
    func initSubscriptions() {
        
        $groupTitle
            .map { $0.trimTrailingWhiteSpaces().count > 0}
            .sink { [weak self] in self?.validTitle = $0 }
            .store(in: &subscriptions)
        
        $selectedUsers
            .map { $0.count > 0 }
            .sink { [weak self] in self?.validMembers = $0 }
            .store(in: &subscriptions)
        
        Publishers.CombineLatest($validTitle, $validMembers)
            .map { $0 && $1 }
            .sink { [weak self] in self?.canCreate = $0 }
            .store(in: &subscriptions)
    }
    func observeSelection(_ listener: PassthroughSubject<[Users],Never>) {
        listener
            .sink { [weak self] in self?.selectedUsers = $0}
            .store(in: &subscriptions)
    }
    func getPlayerUploadPoints(_ groupID: String) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        selectedUsers.append(UserDefaults.currentUser)
        for player in selectedUsers {
            uploadPoints.append(FirebaseMultiUploadDataPoint(value: true, path: "GroupsReferences/\(player.uid)/\(groupID)"))
        }
        return uploadPoints
    }
    func getLeaderReference(_ groupID: String) -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: true, path: "GroupsLeaderReferences/\(UserDefaults.currentUser.uid)/\(groupID)")
    }
    func getGroupMembers(_ groupID: String) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        for player in selectedUsers {
            uploadPoints.append(FirebaseMultiUploadDataPoint(value: true, path: "GroupMembers/\(groupID)/\(player.uid)"))
        }
        return uploadPoints
    }
}

struct NewGroupModel {
    var title: String = ""
    var description: String = ""
    var players: [Users] = []
}
