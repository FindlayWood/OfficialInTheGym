//
//  WorkoutUploaderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 25/05/2024.
//

import XCTest

private class RemoteWorkoutUploader {
    
    let uploader: WorkoutUploader
    let model: UploadWorkoutModel
    
    init(uploader: WorkoutUploader, model: UploadWorkoutModel) {
        self.uploader = uploader
        self.model = model
    }
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public typealias Result = WorkoutUploader.Result
    
    func upload(completion: @escaping (Result) -> Void) {
        uploader.upload(model) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case .success:
                completion(.success(true))
            }
        }
    }
}

final class WorkoutUploaderTests: XCTestCase {

    func test_init_doesNotRequestToCreateWorkout() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedPaths.isEmpty)
    }
    
    func test_upload_requestsToCreateWorkout() {
        let model = makeUploadModel()
        let (client, sut) = makeSUT(with: model)
        
        sut.upload { _ in }
        
        XCTAssertEqual(client.requestedPaths, [model.id])
    }
    
    func test_uploadTwice_requestsToCreateWorkoutTwice() {
        let model = makeUploadModel()
        let (client, sut) = makeSUT(with: model)
        
        sut.upload { _ in }
        sut.upload { _ in }
        
        XCTAssertEqual(client.requestedPaths, [model.id, model.id])
    }
    
    func test_upload_deliversErrorOnClientError() {
        let model = makeUploadModel()
        let (client, sut) = makeSUT(with: model)
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            
            client.complete(with: clientError)
        }
    }
    
    func test_upload_deliversTrueOnSuccessfulUpload() {
        
        let (client, sut) = makeSUT()
        
        let model = makeUploadModel()

        expect(sut, toCompleteWith: .success(true)) {
            client.complete(withModel: model)
        }
    }
    
    func test_upload_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let uploader = WorkoutUploaderSpy()
        let model = makeUploadModel()
        var sut: RemoteWorkoutUploader? = RemoteWorkoutUploader(uploader: uploader, model: model)

        var capturedResults = [RemoteWorkoutUploader.Result]()
        sut?.upload { capturedResults.append($0) }

        sut = nil
        uploader.complete(withModel: model)

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers
    private func makeSUT(with uploadModel: UploadWorkoutModel? = nil, file: StaticString = #filePath, line: UInt = #line) -> (WorkoutUploaderSpy, RemoteWorkoutUploader) {
        let client = WorkoutUploaderSpy()
        let sut = RemoteWorkoutUploader(uploader: client, model: uploadModel ?? makeUploadModel())
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (client, sut)
    }
    
    private func failure(_ error: RemoteWorkoutUploader.Error) -> RemoteWorkoutUploader.Result {
        return .failure(error)
    }
    
    private func makeUploadModel() -> UploadWorkoutModel {
        UploadWorkoutModel(title: "Title", exercises: [], tags: [], isPublic: true, savedID: UUID().uuidString, createdByID: UUID().uuidString, id: UUID().uuidString)
    }
    
    private func expect(_ sut: RemoteWorkoutUploader, toCompleteWith expectedResult: RemoteWorkoutUploader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.upload { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteWorkoutUploader.Error), .failure(expectedError as RemoteWorkoutUploader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private class WorkoutUploaderSpy: WorkoutUploader {
        
        private var messages = [(model: UploadWorkoutModel, completion: (WorkoutUploader.Result) -> Void)]()
        
        var requestedPaths: [String] {
            messages.map { $0.model.id }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withModel model: UploadWorkoutModel, at index: Int = 0) {
            messages[index].completion(.success(true))
        }
        
        func upload(_ model: UploadWorkoutModel, completion: @escaping (WorkoutUploader.Result) -> Void) {
            messages.append((model, completion))
        }
    }
}
