//
//  DisplayableComment.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

protocol DisplayableComment {
    var id: String { get }
    var time: TimeInterval { get }
    var comment: String { get }
    var posterID: String { get }
    var likeCount: Int { get }
    var replyCount: Int { get }
    var username: String { get }
}
