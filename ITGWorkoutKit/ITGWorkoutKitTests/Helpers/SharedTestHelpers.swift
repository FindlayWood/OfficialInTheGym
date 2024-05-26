//
//  SharedTestHelpers.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 14/04/2024.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("Invalid json".utf8)
}
