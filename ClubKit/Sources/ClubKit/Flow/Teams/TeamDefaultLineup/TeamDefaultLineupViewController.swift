//
//  TeamDefaultLineupViewController.swift
//  
//
//  Created by Findlay-Personal on 07/06/2023.
//

import UIKit

class TeamDefaultLineupViewController: UIViewController {

    var coordinator: TeamFlow?
    
    var viewModel: TeamDefaultLineupViewModel
    var display: TeamDefaultLineupView!
    
    init(viewModel: TeamDefaultLineupViewModel) {
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
        initNavBar()
        view.backgroundColor = .systemBackground
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Lineup"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(editLineup))
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Actions
    @objc func editLineup(_ sender: UIBarButtonItem) {
        viewModel.isEditing = true
    }
    
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.loadDefaultLineup()
        
        viewModel.addNewPlayer = { [weak self] index in
            guard let self else { return }
            self.addPlayer(at: index)
        }
    }
    
    func addPlayer(at index: Int) {
        let excludedPlayers = viewModel.playerModels.map { $0.playerModel }
        coordinator?.showPlayersList(for: viewModel.team, excluding: excludedPlayers, selectedAction: { [weak self] selectedPlayer in
            guard let self else { return }
            self.viewModel.addPlayerToLineup(selectedPlayer, at: index)
            self.navigationController?.dismiss(animated: true)
        })
    }
}

protocol UploadLineupService {
    func uploadLineup(with data: UploadLineupModel) async -> Result<UploadLineupModel,RemoteUploadLineupService.Error>
}

struct RemoteUploadLineupService: UploadLineupService {
    
    var client: Client
    
    public enum Error: Swift.Error {
        case failed
    }
    
    func uploadLineup(with data: UploadLineupModel) async -> Result<UploadLineupModel,Error> {
        
        do {
            let jsonData = try JSONEncoder().encode(data.selectedPlayers)
            guard let json = String(data: jsonData, encoding: .utf8) else { return .failure(.failed) }
            let functionData: [String: Any] = [
                "clubID": data.clubID,
                "teamID": data.teamID,
                "name": data.name,
                "selectedPlayers": json,
                "lineupID": data.lineupID
            ]
            try await client.callFunction(named: "uploadDefaultLineup", with: functionData)
            return .success(data)
        } catch {
            return .failure(.failed)
        }
    }
}
