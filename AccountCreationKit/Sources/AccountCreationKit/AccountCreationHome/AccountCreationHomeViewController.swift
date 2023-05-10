//
//  AccountCreationHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import UIKit

class AccountCreationHomeViewController: UIViewController {
    
    var viewModel: AccountCreationHomeViewModel!
    
    var display: HomeView!
    
    var colour: UIColor!
    
    var image: UIImage!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel, colour: colour, image: image)
        addSwiftUIView(display)
    }
}
