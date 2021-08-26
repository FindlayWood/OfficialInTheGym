//
//  UploadCellProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol UploadCellConfigurable: CellReSizable {
    func setup(with model: UploadCellModelProtocol)
    var delegate: UploadingCellActions? { get set }
}

protocol CellReSizable {
    func cellSize(text: String) -> CGSize
}

protocol UploadCellModelProtocol {
    var title: String {get}
    var message: String {get}
    var value: Bool {get set}
}

struct SavingUploadCellModel {
    var title: String
    var message: String
    var isSaving: Bool
}
extension SavingUploadCellModel: UploadCellModelProtocol {
    var value: Bool {
        get {
            return isSaving
        }
        set {
            isSaving = newValue
        }
    }
}

struct PrivacyUploadCellModel {
    var title: String
    var message: String
    var isPrivate: Bool
}
extension PrivacyUploadCellModel: UploadCellModelProtocol {
    var value: Bool {
        get {
            return isPrivate
        }
        set {
            isPrivate = newValue
        }
    }
}
