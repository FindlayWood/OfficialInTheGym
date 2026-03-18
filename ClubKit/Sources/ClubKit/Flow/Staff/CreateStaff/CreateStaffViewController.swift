//
//  CreateStaffViewController.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import UIKit

class CreateStaffViewController: UIViewController {

    var viewModel: CreateStaffViewModel
    private lazy var display = CreateStaffView(viewModel: viewModel)
    
    init(viewModel: CreateStaffViewModel) {
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
        navigationItem.title = "Create New Staff"
        editNavBarColour(to: .darkColour)
    }
    func addDisplay() {
        addSwiftUIView(display)
    }
}
