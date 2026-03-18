//
//  WorkoutFeedMapperTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 13/07/2024.
//

import XCTest
import ITGWorkoutKit

final class WorkoutFeedItemsMapperTests: XCTestCase {

    func test_map_throwsErrorOnSuccessfulResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(
            try WorkoutFeedItemsMapper.map(invalidJSON)
        )
    }

    func test_map_deliversNoItemsOnSuccessfulResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])

        let result = try WorkoutFeedItemsMapper.map(emptyListJSON)

        XCTAssertEqual(result, [])
    }

    func test_map_deliversItemsOnSuccessfulResponseWithJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            addedToListDate: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            createdDate: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            creatorID: "creator ID",
            exerciseCount: 1,
            savedWorkoutID: UUID(),
            title: "a title")
        
        let item2 = makeItem(
            id: UUID(),
            addedToListDate: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            createdDate: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            creatorID: "another creator ID",
            exerciseCount: 3,
            savedWorkoutID: UUID(),
            title: "another title")

        let json = makeItemsJSON([item1.json, item2.json])

        let result = try WorkoutFeedItemsMapper.map(json)

        XCTAssertEqual(result, [item1.model, item2.model])
    }

    // MARK: - Helpers

    private func makeItem(id: UUID,
                          addedToListDate: (date: Date, iso8601String: String),
                          createdDate: (date: Date, iso8601String: String),
                          creatorID: String,
                          exerciseCount: Int,
                          savedWorkoutID: UUID,
                          title: String
    ) -> (model: WorkoutFeedItem, json: [String: Any]) {
        
        let item = WorkoutFeedItem(id: id, addedToListDate: addedToListDate.date, createdDate: createdDate.date, creatorID: creatorID, exerciseCount: exerciseCount, savedWorkoutID: savedWorkoutID, title: title)

        let json: [String: Any] = [
            "id": id.uuidString,
            "addedToListDate": addedToListDate.iso8601String,
            "createdDate": createdDate.iso8601String,
            "creatorID": creatorID,
            "exerciseCount": exerciseCount,
            "savedWorkoutID": savedWorkoutID.uuidString,
            "title": title
        ]

        return (item, json)
    }


}
