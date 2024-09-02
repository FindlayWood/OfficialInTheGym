//
//  WelcomeViewController.swift
//  
//
//  Created by Findlay-Personal on 05/04/2023.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var display: WelcomeView!
    
    var viewModel: WelcomeViewModel!
    
    var colour: UIColor!
    var image: UIImage!
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel, image: image, colour: colour)
        addSwiftUIView(display)
    }
}
