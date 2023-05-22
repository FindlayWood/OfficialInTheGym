//
//  TeamsViewController.swift
//  
//
//  Created by Findlay-Personal on 21/05/2023.
//

import UIKit

class TeamsViewController: UIViewController {
    
    var clubModel: RemoteClubModel
    var teamLoader: TeamLoader
    
    private lazy var viewModel: TeamsViewModel = TeamsViewModel(clubModel: clubModel, teamLoader: teamLoader)
    private lazy var display: TeamsView = TeamsView(viewModel: viewModel)
    
    init(clubModel: RemoteClubModel, teamLoader: TeamLoader) {
        self.clubModel = clubModel
        self.teamLoader = teamLoader
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = viewModel.clubModel.clubName
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(addNewTeam))
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Display
    func addDisplay() {
        addSwiftUIView(display)
    }
    
    // MARK: - Actions
    @objc func addNewTeam(_ sender: UIBarButtonItem) {
        
    }
}
