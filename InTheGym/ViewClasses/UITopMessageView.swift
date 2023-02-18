//
//  UITopMessageView.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - Top Message View
///Displays a message at the top of the screen for a brief period of time
class UITopMessageView: UIViewController {
    
    // MARK: - Properties
    var childContentView: UIView!

    // MARK: - Subviews
    struct UIView: View {
        let imageName: String
        let message: String
        var body: some View {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                Text(message)
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.darkColour))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func addChildView(_ text: String, image: String) {
        childContentView = .init(imageName: image, message: text)
        addSwiftUIView(childContentView)
    }
}


