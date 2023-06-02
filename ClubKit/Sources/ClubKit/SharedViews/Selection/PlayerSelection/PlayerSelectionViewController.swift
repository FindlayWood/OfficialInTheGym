//
//  PlayerSelectionViewController.swift
//  
//
//  Created by Findlay-Personal on 30/05/2023.
//

import UIKit

class PlayerSelectionViewController: UIViewController {
    
    var clubModel: RemoteClubModel
    var playerLoader: PlayerLoader
    
    private lazy var viewModel = PlayerSelectionViewModel(clubModel: clubModel, playerLoader: playerLoader)
    private lazy var display = PlayerSelectionView(viewModel: viewModel)
    
    init(clubModel: RemoteClubModel, playerLoader: PlayerLoader) {
        self.clubModel = clubModel
        self.playerLoader = playerLoader
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
    
    // MARK: - Display
    func addDisplay() {
        addSwiftUIView(display)
    }
}
