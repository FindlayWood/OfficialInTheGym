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
    @Published var isLoading: Bool = false
    @Published var groupTitle: String = ""
    @Published private var validTitle: Bool = false
    @Published private var validMembers: Bool = false
    @Published var canCreate: Bool = false
    
    var newUsersSelected = CurrentValueSubject<[Users],Never>([])
    weak var createdNewGroup: PassthroughSubject<GroupModel,Never>?
    var errorCreatingGroup = PassthroughSubject<Error,Never>()
    
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
        isLoading = true
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
                self?.groupTitle = ""
                self?.newUsersSelected.send([])
                self?.createdNewGroup?.send(newGroup)
                self?.isLoading = false
            case .failure(let error):
                self?.errorCreatingGroup.send(error)
            }
        }
    }

    
    // MARK: - Functions
    func initSubscriptions() {
        
        newUsersSelected
            .map { $0.count > 0}
            .sink { [weak self] in self?.validMembers = $0 }
            .store(in: &subscriptions)
        
        $groupTitle
            .map { $0.trimTrailingWhiteSpaces().count > 0}
            .sink { [weak self] in self?.validTitle = $0 }
            .store(in: &subscriptions)
        
        
        Publishers.CombineLatest($validTitle, $validMembers)
            .map { $0 && $1 }
            .sink { [weak self] in self?.canCreate = $0 }
            .store(in: &subscriptions)
    }

    func getPlayerUploadPoints(_ groupID: String) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        var users = newUsersSelected.value
        users.append(UserDefaults.currentUser)
        for user in users {
            uploadPoints.append(FirebaseMultiUploadDataPoint(value: true, path: "GroupsReferences/\(user.uid)/\(groupID)"))
        }
        return uploadPoints
    }
    func getLeaderReference(_ groupID: String) -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: true, path: "GroupsLeaderReferences/\(UserDefaults.currentUser.uid)/\(groupID)")
    }
    func getGroupMembers(_ groupID: String) -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        var users = newUsersSelected.value
        users.append(UserDefaults.currentUser)
        for user in users {
            uploadPoints.append(FirebaseMultiUploadDataPoint(value: true, path: "GroupMembers/\(groupID)/\(user.uid)"))
        }
        return uploadPoints
    }
}
