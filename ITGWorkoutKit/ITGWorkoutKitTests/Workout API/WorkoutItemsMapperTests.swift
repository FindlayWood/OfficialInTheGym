//
//  WorkoutItemsMapperTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 27/05/2024.
//

import XCTest
import ITGWorkoutKit

class WorkoutItemsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try WorkoutItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(
            try WorkoutItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }

    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])

        let result = try WorkoutItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [])
    }

    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            image: URL(string: "http://a-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "example 2",
            location: "a location",
            image: URL(string: "http://another-url.com")!)

        let json = makeItemsJSON([item1.json, item2.json])

        let result = try WorkoutItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [item1.model, item2.model])
    }

    // MARK: - Helpers

    private func failure(_ error: RemoteWorkoutLoader.Error) -> RemoteWorkoutLoader.Result {
        return .failure(error)
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, image: URL) -> (model: WorkoutItem, json: [String: Any]) {
        
        let item = WorkoutItem(id: id, description: description, location: location, image: image)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": image.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
