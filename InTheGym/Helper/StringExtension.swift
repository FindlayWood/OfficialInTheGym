//
//  StringExtension.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

extension String {
    func trimTrailingWhiteSpaces() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
}
