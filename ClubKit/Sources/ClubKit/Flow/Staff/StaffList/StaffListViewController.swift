//
//  StaffListViewController.swift
//  
//
//  Created by Findlay Wood on 24/11/2023.
//

import UIKit

class StaffListViewController: UIViewController {
    
    var coordinator: StaffFlow?
    
    var viewModel: StaffListViewModel
    private lazy var display = StaffListView(viewModel: viewModel)
    
    init(viewModel: StaffListViewModel) {
        self.viewModel = viewModel
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
        navigationItem.title = viewModel.clubModel.clubName + "'s Staff"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(addNewPlayer))
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Actions
    @objc func addNewPlayer(_ sender: UIBarButtonItem) {
        coordinator?.addNewStaffMember()
    }
    
    // MARK: - Display
    func addDisplay() {
        addSwiftUIViewWithNavBar(display)
    }
}
