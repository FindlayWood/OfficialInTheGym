//
//  ClubCreationViewController.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

class ClubCreationViewController: UIViewController {
    
    var viewModel: ClubCreationViewModel
    var display: ClubCreationView!
    
    init(viewModel: ClubCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Club Creation"
    }
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
}


struct ClubCreationUIComposer {
    
    private init() {}
    
    static func composeCreation(with networkService: NetworkService) -> ClubCreationViewController {
        let service = RemoteCreationService(client: FirebaseClient(service: networkService))
        let viewModel = ClubCreationViewModel(service: service)
        let vc = ClubCreationViewController(viewModel: viewModel)
        return vc
    }
}


protocol CreationService {
    func createNewClub(with data: NewClubData) async -> Result<NewClubData,RemoteCreationService.Error>
}

protocol Client {
    func callFunction(named: String, with data: Any) async throws
}

struct FirebaseClient: Client {
    
    var service: NetworkService
    
    func callFunction(named: String, with data: Any) async throws {
        try await service.callFunction(named: named, with: data)
    }
}

struct NewClubData {
    let id: String = UUID().uuidString
    let displayName: String
    let tagline: String
    let sport: Sport
    let isPrivate: Bool
}

struct RemoteCreationService: CreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewClub(with data: NewClubData) async -> Result<NewClubData,Error> {
        do {
            try await client.callFunction(named: "createClub", with: data)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}

