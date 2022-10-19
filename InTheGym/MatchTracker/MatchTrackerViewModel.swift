//
//  MatchTrackerViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore

class MatchTrackerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    
    // MARK: - Previous Models
    @Published var previousMatchModels: [MatchTrackerModel] = []
    
    // MARK: - New Model
    @Published var uploadedMatchTrackerModel: MatchTrackerModel?
    
    // MARK: - Ratings
    @Published var overallRating: Int = 5
    @Published var physicalRating: Int = 5
    @Published var technicalRating: Int = 5
    @Published var tacticalRating: Int = 5
    @Published var mentalRating: Int = 5
    
    @Published var note: String = ""
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Load Models
    @MainActor
    func load() async {
        let matchTrackerSearchModel = MatchTrackerSearchModel(id: UserDefaults.currentUser.uid)
        do {
            let models: [MatchTrackerModel] = try await apiService.fetchInstanceAsync(of: matchTrackerSearchModel)
            previousMatchModels = models
        } catch {
            print(String(describing: error))
        }
    }
    
    // MARK: - Methods
    func upload() {
        loadWorkloads()
    }
    
    // MARK: - Functions
    func loadWorkloads() {
        isLoading = true
        let workloadSearchModel = WorkloadSearchModel(id: UserDefaults.currentUser.uid)
        apiService.fetchInstance(of: workloadSearchModel, returning: WorkloadModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let models):
                let ratioModel = self.loadData(from: models)
                Task {
                    let cmjModel = await self.loadCMJModel()
                    let wellnessModel = await self.loadWellnessModel()
                    await self.uploadMatchTrackerModel(workloadModel: models.first, ratioModel: ratioModel, CMJModel: cmjModel, WellnessModel: wellnessModel)
                }
            case .failure(let error):
                self.isLoading = false
                print(String(describing: error))
            }
        }
    }
    
    // MARK: - Upload
    @MainActor
    func uploadMatchTrackerModel(workloadModel: WorkloadModel?, ratioModel: RatioModel?, CMJModel: CMJModel?, WellnessModel: WellnessAnswersModel?) async {
        var matchTrackerModel = MatchTrackerModel(id: UUID().uuidString,
                                                  userID: UserDefaults.currentUser.uid,
                                                  date: Date().timeIntervalSince1970,
                                                  overallRating: overallRating,
                                                  technicalRating: technicalRating,
                                                  tacticalRating: tacticalRating,
                                                  physicalRating: physicalRating,
                                                  mentalRating: mentalRating,
                                                  notes: note,
                                                  workloadRatio: ratioModel,
                                                  mostRecentWorkload: workloadModel,
                                                  wellnessStatus: WellnessModel,
                                                  cmjModel: CMJModel)
        
        var matchWorkloadModel = WorkloadModel(id: UUID().uuidString,
                                               endTime: Date().timeIntervalSince1970,
                                               rpe: 10,
                                               timeToComplete: 120,
                                               workload: 0,
                                               customAddedWorkload: 0,
                                               matchWorkload: 1000)
        
        do {
            let model = try await apiService.uploadTimeOrderedModelAsync(data: &matchTrackerModel)
            matchWorkloadModel.workoutID = model.id
            let _ = try await apiService.uploadTimeOrderedModelAsync(data: &matchWorkloadModel)
            uploadedMatchTrackerModel = model
            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
    
    
    func loadData(from models: [WorkloadModel]) -> RatioModel {
        let shortModels = loadModelRanges(from: 0, to: 7, from: models, with: 7)
        let longModels = loadModelRanges(from: 0, to: 28, from: models, with: 28)
        let ratioModel = calculateData(from: shortModels, compared: longModels)
        return ratioModel
    }
    
    func loadModelRanges(from startDay: Int, to endDay: Int, from models: [WorkloadModel], with size: Int) -> [Double] {
        var workloads = Array(repeating: 0.0, count: size)
        let models = models.filter { $0.endTime.daysAgo() >= startDay && $0.endTime.daysAgo() < endDay }
        let addedWorkloads = getOccurences( models.map { $0.endTime.daysAgo() }, models.map { Double($0.workload) + Double($0.customAddedWorkload ?? 0) })
        for (key, value) in addedWorkloads {
            workloads[key - startDay] = value
        }
        return workloads
    }
    func getOccurences(_ days: [Int], _ workloads: [Double]) -> [Int:Double] {
        var occureneces = [Int:Double]()
        for (index, value) in days.enumerated() {
            occureneces[value, default: 0] += workloads[index]
        }
        return occureneces
    }
    func calculateData(from sevenDayModels: [Double], compared twentyEightDayModels: [Double]) -> RatioModel {
        let acwr = sevenDayModels.sum() / (twentyEightDayModels.sum() / 4)
        let monotony = sevenDayModels.avg() / sevenDayModels.stdev()
        let trainingStrain = sevenDayModels.sum() * monotony
        let acuteLoad = sevenDayModels.sum()
        let chronicLoad = twentyEightDayModels.sum() / 4
        let freshnessIndex = chronicLoad - acuteLoad
        return RatioModel(acwr: acwr, monotony: monotony, trainingStrain: trainingStrain, acuteLoad: acuteLoad, chronicLoad: chronicLoad, freshnessIndex: freshnessIndex)
    }
    func loadWellnessModel() async -> WellnessAnswersModel? {
        let dbref = Firestore.firestore().collection("WellnessScores").document(UserDefaults.currentUser.uid)
        do {
            let model = try await dbref.getDocument(as: WellnessAnswersModel.self)
            return model
        } catch {
            print("Wellness failed")
            return nil
        }
    }
    func loadCMJModel() async -> CMJModel? {
        let dbref = Firestore.firestore().collection("CMJ").document(UserDefaults.currentUser.uid)
        do {
            let model = try await dbref.getDocument(as: CMJModel.self)
            return model
        } catch {
            print("CMJ failed")
            return nil
        }
    }
}
