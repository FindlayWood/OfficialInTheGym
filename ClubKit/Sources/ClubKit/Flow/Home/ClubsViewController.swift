//
//  ClubsViewController.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

class ClubsViewController: UIViewController {
    
    var clubManager: ClubManager
    var coordinator: ClubsFlow
    
    lazy var viewModel = ClubsViewModel(clubManager: clubManager, flow: coordinator)
    lazy var display = ClubsView(viewModel: viewModel)
    
    init(clubManager: ClubManager, coordinator: ClubsFlow) {
        self.clubManager = clubManager
        self.coordinator = coordinator
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
        navigationController?.navigationBar.isHidden = true
    }
    func addDisplay() {
        addSwiftUIView(display)
    }
}
