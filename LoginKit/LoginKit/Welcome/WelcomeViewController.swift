//
//  WelcomeViewController.swift
//  
//
//  Created by Findlay-Personal on 05/04/2023.
//

import SwiftUI
import UIKit

class WelcomeViewController: UIViewController {
    
    var display: WelcomeView!
    
    var viewModel: WelcomeViewModel!
    
    var image: UIImage!
    

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    
    /// The welcome screen draws its own header, so the bar is hidden here. Every screen pushed from
    /// it shows the bar again itself (`editNavBarColour()`, the previews' routers), so it is only
    /// ever hidden on this one. The tint is set here too: the previews are pushed before any screen
    /// that calls `editNavBarColour()`, and their back chevron would otherwise be system blue.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.navigationBar.tintColor = UIColor(Color.darkColor)
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel, image: image)
        addSwiftUIView(display)
    }
}
