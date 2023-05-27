//
//  PlayersViewController.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import UIKit

class PlayersViewController: UIViewController {
    
    var clubModel: RemoteClubModel
    var coordinator: ClubHomeFlow?
    var playerLoader: PlayerLoader
    
    private lazy var viewModel = PlayersViewModel(clubModel: clubModel, playerLoader: playerLoader)
    private lazy var display = PlayersView(viewModel: viewModel)
    
    init(clubModel: RemoteClubModel, playerLoader: PlayerLoader) {
        self.clubModel = clubModel
        self.playerLoader = playerLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        view.backgroundColor = .systemBackground
        addDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = clubModel.clubName + "'s Players"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(addNewPlayer))
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Actions
    @objc func addNewPlayer(_ sender: UIBarButtonItem) {
        coordinator?.goToCreatePlayer()
    }
    
    // MARK: - Display
    func addDisplay() {
        addSwiftUIView(display)
    }
}
