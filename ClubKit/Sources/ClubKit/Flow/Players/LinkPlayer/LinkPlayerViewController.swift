//
//  LinkPlayerViewController.swift
//  
//
//  Created by Findlay-Personal on 03/12/2023.
//

import UIKit

class LinkPlayerViewController: UIViewController {

    var viewModel: LinkPlayerViewModel
    private lazy var display = LinkPlayerView(viewModel: viewModel)
    
    init(viewModel: LinkPlayerViewModel) {
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
        navigationItem.title = "Scan QR"
        editNavBarColour(to: .darkColour)
    }
    func addDisplay() {
        addSwiftUIView(display)
    }
}
