//
//  HTTPURLResponse+StatusCode.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 28/05/2024.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
