//
//  CreatePlayerViewController.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import UIKit

class CreatePlayerViewController: UIViewController {
    
//    var clubModel: RemoteClubModel
//    var loader: PlayerLoader
//    var teamLoader: TeamLoader
    
    var viewModel: CreatePlayerViewModel
    private lazy var display = CreatePlayerView(viewModel: viewModel)
    
    init(viewModel: CreatePlayerViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Create New Player"
        editNavBarColour(to: .darkColour)
    }
    func addDisplay() {
        addSwiftUIView(display)
    }
}

protocol PlayerCreationService {
    func createNewPlayer(with data: NewPlayerData) async -> Result<NewPlayerData,RemotePlayerCreationService.Error>
}

struct NewPlayerData {
    let playerID: String = UUID().uuidString
    let displayName: String
    let clubID: String
    let positions: [String]
    let selectedTeams: [String]
}

struct RemotePlayerCreationService: PlayerCreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewPlayer(with data: NewPlayerData) async -> Result<NewPlayerData,Error> {
        let functionData: [String: Any] = [
            "clubID": data.clubID,
            "playerID": data.playerID,
            "displayName": data.displayName,
            "positions": data.positions,
            "selectedTeams": data.selectedTeams
        ]
        do {
            try await client.callFunction(named: "createPlayer", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}
