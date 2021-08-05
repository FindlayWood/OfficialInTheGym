//
//  DisplayExerciseStatsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class DisplayExerciseStatsViewModel {
    
    var reloadCollectionViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var filteredResultsClosure: (() -> ())?
    
    var firebaseService: FirebaseAPILoader!
    
    var exercises: [DisplayExerciseStatsModel] = [] {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var filteredExercises: [DisplayExerciseStatsModel] = [] {
        didSet {
            self.filteredResultsClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    var numberOfItems: Int {
        return exercises.count
    }
    var numberOfFilteredItems: Int {
        return filteredExercises.count
    }
    
    init(firebaseService: FirebaseAPILoader) {
        self.firebaseService = firebaseService
    }
    
    func fetchData() {
        isLoading = true
        firebaseService.loadExerciseStats { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self.isLoading = false
            case .success(let statsArray):
                self.exercises = statsArray
                self.isLoading = false
            }
        }
    }
    
    func getData(from exercisesToDisplay: [DisplayExerciseStatsModel], at indexPath: IndexPath) -> DisplayExerciseStatsModel {
        return exercisesToDisplay[indexPath.section]
    }
    func getTitleCellData(from exercisesToDisplay: [DisplayExerciseStatsModel], at indexPath: IndexPath) -> String {
        return exercisesToDisplay[indexPath.section].exerciseName
    }
    func getSectionCellData(from exercisesToDisplay: [DisplayExerciseStatsModel], at indexPath: IndexPath) -> SectionCellModel {
        
        switch indexPath.row {
        case 1:
            let data = exercisesToDisplay[indexPath.section].maxWeight.description
            return SectionCellModel(title: "Max Weight", data: data + "kg")
        case 2:
            let data = exercisesToDisplay[indexPath.section].averageWeight.rounded(toPlaces: 2).description
            return SectionCellModel(title: "Average Weight", data: data + "kg")
        case 3:
            let data = exercisesToDisplay[indexPath.section].totalWeight.description
            return SectionCellModel(title: "Total Weight", data: data + "kg")
        case 4:
            return SectionCellModel(title: "Total Reps", data: exercisesToDisplay[indexPath.section].numberOfReps.description)
        case 5:
            return SectionCellModel(title: "Total Sets", data: exercisesToDisplay[indexPath.section].numberOfSets.description)
        case 6:
            return SectionCellModel(title: "Average RPE", data: exercisesToDisplay[indexPath.section].averageRPEScore.description)
        default:
            return SectionCellModel(title: "Max Weight", data: "100kg")
        }
        
    }
    func getSectionState(from exercisesToDisplay: [DisplayExerciseStatsModel], at section: Int) -> sectionState {
        return exercisesToDisplay[section].sectionState
        
    }
    
    func filterExercises(from input: String) {
        filteredExercises = exercises.filter({$0.exerciseName.lowercased().contains(input.lowercased())})
    }
}
