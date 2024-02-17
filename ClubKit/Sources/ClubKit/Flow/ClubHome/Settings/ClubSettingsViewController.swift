//
//  ClubSettingsViewController.swift
//  
//
//  Created by Findlay Wood on 07/02/2024.
//

import UIKit

class ClubSettingsViewController: UIViewController {
    
    var viewModel: ClubSettingsViewModel
    var display: ClubSettingsView!
    var coordinator: ClubHomeFlow?
    
    init(viewModel: ClubSettingsViewModel) {
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
        navigationItem.title = "Settings"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        
    }
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIViewWithNavBar(display)
    }
    
    func initViewModel() {
        
        viewModel.successfulDelete = { [weak self] in
            guard let self else { return }
            self.coordinator?.popToRoot()
        }
    }

}
