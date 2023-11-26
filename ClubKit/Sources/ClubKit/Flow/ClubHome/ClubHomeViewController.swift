//
//  ClubHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

class ClubHomeViewController: UIViewController {
    
    var clubModel: RemoteClubModel
    var coordinator: ClubHomeFlow?
    
    lazy var viewModel = ClubHomeViewModel(clubModel: clubModel)
    lazy var display = ClubHomeView(viewModel: viewModel)
    
    init(clubModel: RemoteClubModel) {
        self.clubModel = clubModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = viewModel.clubModel.clubName
        editNavBarColour(to: .darkColour)
    }
    func addDisplay() {
        addSwiftUIView(display)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.goToTeams = { [weak self] in
            self?.coordinator?.goToTeams()
        }
        viewModel.goToPlayers = { [weak self] in
            self?.coordinator?.goToPlayers()
        }
        viewModel.goToGroups = { [weak self] in
            self?.coordinator?.goToGroups()
        }
        viewModel.goToStaff = { [weak self] in
            self?.coordinator?.goToStaff()
        }
        viewModel.goToQRScanner = { [weak self] in
            self?.coordinator?.goToQRScanner()
        }
    }
}
