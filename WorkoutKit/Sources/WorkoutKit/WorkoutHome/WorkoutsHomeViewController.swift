//
//  WorkoutsHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import UIKit

class WorkoutsHomeViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: WorkoutsHomeViewModel!
    
    var display: WorkoutsHomeView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
}
