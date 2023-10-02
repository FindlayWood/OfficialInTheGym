//
//  CreateTeamViewController.swift
//  
//
//  Created by Findlay Wood on 01/10/2023.
//

import UIKit

class CreateTeamViewController: UIViewController {
    
    var viewModel: CreateTeamViewModel
    var display: CreateTeamView!
    
    init(viewModel: CreateTeamViewModel) {
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
        navigationItem.title = "Create New Team"
        editNavBarColour(to: .darkColour)
    }
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
}


protocol TeamCreationService {
    func createNewTeam(with data: NewTeamData) async -> Result<NewTeamData,RemoteTeamCreationService.Error>
}

struct NewTeamData {
    let displayName: String
    let clubID: String
    let teamID: String = UUID().uuidString
    let isPrivate: Bool
    let sport: Sport
}

struct RemoteTeamCreationService: TeamCreationService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func createNewTeam(with data: NewTeamData) async -> Result<NewTeamData,Error> {
        let functionData: [String: Any] = [
            "clubID": data.clubID,
            "teamID": data.teamID,
            "teamName": data.displayName,
            "isPrivate": data.isPrivate,
            "sport": data.sport.rawValue
        ]
        do {
            try await client.callFunction(named: "createTeam", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}
