//
//  ClipProtocols.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

protocol clipUploadingProtocol: AnyObject {
    func clipUploadedAndSaved()
}
protocol addedClipProtocol: AnyObject {
    func clipAdded(with data: clipSuccessData)
}

protocol ClipAdding: AnyObject {
    func addClip(_ model: ClipModel)
}
