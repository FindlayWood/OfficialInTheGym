//
//  TeamDefaultLineupViewController.swift
//  
//
//  Created by Findlay-Personal on 07/06/2023.
//

import UIKit

class TeamDefaultLineupViewController: UIViewController {

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
}
