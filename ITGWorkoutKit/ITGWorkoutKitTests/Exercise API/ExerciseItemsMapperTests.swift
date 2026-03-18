//
//  ExerciseItemsMapperTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 27/05/2024.
//

import XCTest
import ITGWorkoutKit

final class ExerciseItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 150, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ExerciseItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ExerciseItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            let result = try ExerciseItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: code))

            XCTAssertEqual(result, [])
        }
    }

    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            name: "Squat",
            bodyArea: "Lower")
        
        let item2 = makeItem(
            id: UUID(),
            name: "Bench Press",
            bodyArea: "Upper")

        let json = makeItemsJSON([item1.json, item2.json])
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            let result = try ExerciseItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))

            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }

    // MARK: - Helpers

    private func makeItem(id: UUID, name: String, bodyArea: String) -> (model: ExerciseItem, json: [String: Any]) {
        
        let item = ExerciseItem(id: id, name: name, bodyArea: bodyArea)

        let json: [String: Any] = [
            "id": id.uuidString,
            "name": name,
            "bodyArea": bodyArea
        ]

        return (item, json)
    }
}
