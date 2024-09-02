//
//  MyMeasurementsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import Foundation
import FirebaseFirestore

@MainActor
class MyMeasurementsViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var validUploadState: Bool = false
    @Published var showingPopover: Bool = false
    @Published var successfulUpload: Bool = false
    @Published var dismissView: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: MeasurementError?
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var isPrivate: Bool = true
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    deinit {
        print("gone")
    }
    // MARK: - Actions
    func initSubscriptions() {
        
        Publishers.CombineLatest($height, $weight)
            .map { height, weight in
                return height.count > 0 && weight.count > 0
            }
            .sink { [weak self] in self?.validUploadState = $0 }
            .store(in: &subscriptions)
    }
    
    func loadMeasurements() async {
        isLoading = true
        
        let ref = Firestore.firestore().collection("AthleteMeasurements").document(UserDefaults.currentUser.uid)
        
        do {
            let model = try await ref.getDocument(as: MeasurementModel.self)
            self.height = String(model.height)
            self.weight = String(model.weight)
            self.isLoading = false
        } catch {
            self.error = .networkError
            self.isLoading = false
        }
    }
    // MARK: - Functions
    func upload() async {
        isLoading = true
        guard let height = Double(height),
              let weight = Double(weight)
        else {
            error = .inputError
            showingPopover = false
            return}
        let measurementModel = MeasurementModel(userID: UserDefaults.currentUser.uid,
                                                height: height,
                                                weight: weight,
                                                isPrivate: isPrivate,
                                                time: .now)
        
        let ref = Firestore.firestore().collection("AthleteMeasurements").document(UserDefaults.currentUser.uid)
        
        do {
            try await ref.setData(from: measurementModel)
            self.successfulUpload = true
            self.isLoading = false
        } catch {
            self.error = .networkError
            self.showingPopover = false
            self.isLoading = false
        }

//        apiService.upload(data: measurementModel, autoID: false) { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.successfulUpload = true
//                self?.isLoading = false
//            case .failure(_):
//                self?.error = .networkError
//                self?.showingPopover = false
//                self?.isLoading = false
//            }
//        }
    }
    func cancel() {
        dismissView = true
    }
}

enum MeasurementError: Error {
    case inputError
    case networkError
}
