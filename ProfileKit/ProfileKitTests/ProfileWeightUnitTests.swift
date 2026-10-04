//
//  ProfileWeightUnitTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import XCTest
@testable import ProfileKit

final class ProfileWeightUnitTests: XCTestCase {

    func test_display_dropsAWholeNumbersDecimal() {
        XCTAssertEqual(ProfileWeightUnit.kilograms.display(kilograms: 80), "80 kg")
        XCTAssertEqual(ProfileWeightUnit.kilograms.display(kilograms: 80.46), "80.5 kg")
    }

    func test_display_convertsToPounds() {
        XCTAssertEqual(ProfileWeightUnit.pounds.display(kilograms: 80), "176.4 lbs")
    }

    // Stored kilograms are what stats compare. A pound value entered and read
    // back must survive the round trip to the tenth the wheel shows.
    func test_kilograms_roundTripsAPoundValueToTheTenth() {
        let sut = ProfileWeightUnit.pounds

        let kilograms = sut.kilograms(from: 176.4)

        XCTAssertEqual(sut.value(fromKilograms: kilograms), 176.4, accuracy: 0.0001)
    }

    // The raw values are what createAccount validates and stores.
    func test_rawValues_matchTheServer() {
        XCTAssertEqual(ProfileWeightUnit.allCases.map(\.rawValue), ["kilograms", "pounds"])
        XCTAssertEqual(ProfileHeightUnit.allCases.map(\.rawValue), ["centimetres", "feetInches"])
    }
}
