//
//  AddPlayerQRViewController.swift
//  
//
//  Created by Findlay Wood on 26/11/2023.
//

import UIKit

class AddPlayerQRViewController: UIViewController {

    var viewModel: AddPlayerQRViewModel
    private lazy var display = AddPlayerQRView(viewModel: viewModel)
    
    init(viewModel: AddPlayerQRViewModel) {
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
