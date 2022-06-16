//
//  AddCustomWorkloadViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AddCustomWorkloadViewModel {
    // MARK: - Publishers
    @Published var selectedRPE: Int = 0
    @Published var durationText: String = ""
    @Published var canUpload: Bool = false
    @Published var error: Error?
    var successfulUpload: PassthroughSubject<WorkloadModel,Never>?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    func uploadAction() {
        guard let minsToComplete = Int(durationText) else {return}
        let timeToComplete = minsToComplete * 60
        let workload = selectedRPE * minsToComplete
        let workloadModel = WorkloadModel(id: UUID().uuidString,
                                          endTime: Date().timeIntervalSince1970,
                                          rpe: selectedRPE,
                                          timeToComplete: timeToComplete,
                                          workload: 0,
                                          customAddedWorkload: workload)
        apiService.uploadTimeOrderedModel(model: workloadModel) { [weak self] result in
            switch result {
            case .success(let newModel):
                self?.successfulUpload?.send(newModel)
            case .failure(let error):
                self?.error = error
            }
        }
    }
    // MARK: - Functions
    func initSubscriptions() {
        Publishers.CombineLatest($selectedRPE, $durationText)
            .map { selectedRPE, durationText in
                return selectedRPE > 0 && durationText.count > 0
            }
            .sink { [weak self] canUpload in
                self?.canUpload = canUpload
            }
            .store(in: &subscriptions)
    }
}
