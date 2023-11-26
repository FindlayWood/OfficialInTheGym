//
//  QRScannerViewController.swift
//  
//
//  Created by Findlay-Personal on 26/11/2023.
//

import UIKit

class QRScannerViewController: UIViewController {

    var viewModel: QRScannerViewModel
    private lazy var display = QRScannerView(viewModel: viewModel)
    
    init(viewModel: QRScannerViewModel) {
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
