//
//  UploadingWorkoutViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class UploadingWorkoutViewModel {
    
    var reloadCollectionView: (() -> ())?
    
    var isPrivate: Bool = false
    
    var privacyLabel: String = "Public"
    
    var privacyImageName: String = "public_icon"
    
    lazy var items: [UploadCellModelProtocol] = [
        SavingUploadCellModel(title: "Save Workout", message: StaticMessages.savingWorkoutMessage, isSaving: true),
        PrivacyUploadCellModel(title: "Privacy", message: StaticMessages.privacyMessage, isPrivate: false)]
    
    var numberOfItems: Int {
        return items.count
    }
    
    func getData(at indexPath: IndexPath) -> UploadCellModelProtocol {
        return items[indexPath.item]
    }
    
    func savingChanged() {
        items[0].value.toggle()
    }
    func privacyChanged() {
        items[1].value.toggle()
    }
}
