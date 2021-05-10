//
//  DiscussionTapProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol DiscussionTapProtocol {
    func userTapped(on cell:UITableViewCell)
    func likeButtonTapped(on cell:UITableViewCell, sender:UIButton, label: UILabel)
    func workoutTapped(on cell:UITableViewCell)
    func replyButtonTapped()
}
