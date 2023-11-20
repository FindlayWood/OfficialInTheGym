//
//  GroupsListViewController.swift
//  
//
//  Created by Findlay Wood on 19/11/2023.
//

import UIKit

class GroupsListViewController: UIViewController {
    
    var coordinator: GroupFlow?
    
    var viewModel: GroupsListViewModel
    var display: GroupsListView!
    
    init(viewModel: GroupsListViewModel) {
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
        navigationItem.title = "\(viewModel.clubModel.clubName)'s groups"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(addNewTeam))
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
    
    // MARK: - Actions
    @objc func addNewTeam(_ sender: UIBarButtonItem) {

    }
    
    // MARK: - View Model
    func initViewModel() {
        
    }

}
