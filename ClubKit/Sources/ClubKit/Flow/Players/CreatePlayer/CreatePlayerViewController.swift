//
//  CreatePlayerViewController.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import UIKit

class CreatePlayerViewController: UIViewController {
    
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
