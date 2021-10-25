//
//  ExerciseSelectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class ExerciseSelectionViewModel {
    
    var reloadCollectionClosure: (()->())?
    var updateLoadingStatusClosure:(()->())?
    
    var exercises: [[String]] = [["Upper Body"], ["Lower Body"], ["Core"], ["Cardio"]]
    
    var searchedText: [[String]] = [[], [], [], []]
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatusClosure?()
        }
    }
    
    var isFiltering: Bool = false {
        didSet {
            reloadCollectionClosure?()
        }
    }
    
    func loadExercises() {
        self.isLoading = true
        let dbref = Database.database().reference().child("Exercises")
        dbref.observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount)
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                switch child.key {
                case "Upper Body":
                    guard let snap = child.value as? [String] else {return}
                    self.exercises[0] = snap
                case "Lower Body":
                    guard let snap = child.value as? [String] else {return}
                    self.exercises[1] = snap
                case "Core":
                    guard let snap = child.value as? [String] else {return}
                    self.exercises[2] = snap
                case "Cardio":
                    guard let snap = child.value as? [String] else {return}
                    self.exercises[3] = snap
                default:
                    continue
                }
            }
            self.reloadCollectionClosure?()
            self.isLoading = false
        }
    }
    
    func filterExercises(with searchText: String) {
        if searchText.count > 0 {
            for n in 0...exercises.count - 1 {
                searchedText[n] = exercises[n].filter {$0.lowercased().contains(searchText.lowercased().trimTrailingWhiteSpaces())}
            }
            isFiltering = true
        } else {
            isFiltering = false
        }
    }
    
    
}

// MARK: - Protocol Methods
extension ExerciseSelectionViewModel {
    func getData(at indexPath: IndexPath) -> String {
        if isFiltering {
            return searchedText[indexPath.section][indexPath.item]
        } else {
            return exercises[indexPath.section][indexPath.item]
        }
        
    }
    func numberOfSections() -> Int {
        return exercises.count
    }
    func numberOfItems(at section: Int) -> Int {
        if isFiltering {
            return searchedText[section].count
        } else {
            return exercises[section].count
        }
    }
    func getBodyType(from indexPath: IndexPath) -> bodyType {
        switch indexPath.section {
        case 0:
            return .UB
        case 1:
            return .LB
        case 2:
            return .CO
        case 3:
            return .CA
        default:
            return .CU
        }
    }
}
