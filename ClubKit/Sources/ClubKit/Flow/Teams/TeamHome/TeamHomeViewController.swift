//
//  TeamHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 27/05/2023.
//

import UIKit

class TeamHomeViewController: UIViewController {

    var viewModel: TeamHomeViewModel
    var display: TeamHomeView!
    
    init(viewModel: TeamHomeViewModel) {
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
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Team Home"
        editNavBarColour(to: .darkColour)
    }
    
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
}
