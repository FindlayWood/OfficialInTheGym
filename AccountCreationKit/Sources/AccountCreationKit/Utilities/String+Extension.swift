//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/04/2023.
//

import Foundation

extension String {
    func trimTrailingWhiteSpaces() -> String {
        return self.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
}
