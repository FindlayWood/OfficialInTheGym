import XCTest
@testable import ClubKit

final class ClubKitTests: XCTestCase {
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ClubKit().text, "Hello, World!")
    }
    
    func test_club_loading() async throws {
        let sut = makeSUT()
        
        let data = try await sut.loadClubData()
        
        XCTAssertEqual(data.count, 1)
    }
    
    func test_load_club() async throws {
        let sut = makeSUT()
        
        let data = try await sut.loadClub(with: "")
        
        XCTAssertNotNil(data)
    }
    
    func test_load_clubs() async throws {
        let sut = makeSUT()
        
        let count = 5
        
        let dataArray = Array(repeating: RemoteClubData.example, count: count)
        
        let data = try await sut.loadAllClubs(with: dataArray)
        
        XCTAssertEqual(data.count, count)
    }
    
    // MARK: - HELPERS
    
    func makeSUT() -> ClubLoader {
        return ClubLoaderMock()
    }
    
    private class ClubLoaderMock: ClubLoader {
        func loadClub(with id: String) async throws -> RemoteClubModel {
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
            return .example
        }
        
        func loadAllClubs(with clubData: [RemoteClubData]) async throws -> [RemoteClubModel] {
            var clubs: [RemoteClubModel] = []
            for datum in clubData {
                let club = try await loadClub(with: datum.clubID)
                clubs.append(club)
            }
            return clubs
        }
        
        func loadClubData() async throws -> [RemoteClubData] {
            return [.example]
        }
    }
}
