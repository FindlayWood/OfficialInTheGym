//
//  PlayerDetailViewController.swift
//  
//
//  Created by Findlay Wood on 10/12/2023.
//

import UIKit

class PlayerDetailViewController: UIViewController {

    var viewModel: PlayerDetailViewModel
    private lazy var display = PlayerDetailView(viewModel: viewModel)
    
    init(viewModel: PlayerDetailViewModel) {
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
        navigationItem.title = "Player Detail"
        editNavBarColour(to: .darkColour)
    }
    func addDisplay() {
        addSwiftUIView(display)
    }
}