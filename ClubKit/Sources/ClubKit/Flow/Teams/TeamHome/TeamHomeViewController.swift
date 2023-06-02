//
//  TeamHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 27/05/2023.
//

import UIKit

class TeamHomeViewController: UIViewController {

    private lazy var viewModel = TeamHomeViewModel()
    private lazy var display = TeamHomeView(viewModel: viewModel)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    
    func addDisplay() {
        addSwiftUIView(display)
    }
}
