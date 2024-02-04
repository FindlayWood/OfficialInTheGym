//
//  ClubCreationViewController.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

class ClubCreationViewController: UIViewController {
    
    var viewModel: ClubCreationViewModel
    var display: ClubCreationView!
    
    init(viewModel: ClubCreationViewModel) {
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Club Creation"
    }
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIViewWithNavBar(display)
    }
}


struct ClubCreationUIComposer {
    
    private init() {}
    
    static func composeCreation(with networkService: NetworkService, clubManager: ClubManager) -> ClubCreationViewController {
        let service = RemoteCreationService(client: FirebaseClient(service: networkService))
        let viewModel = ClubCreationViewModel(service: service, clubManager: clubManager)
        let vc = ClubCreationViewController(viewModel: viewModel)
        return vc
    }
}
