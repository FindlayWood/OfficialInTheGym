//
//  CustomTopView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/11/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CustomTopView: UIView {

    var label = UILabel()
    var imageView = UIImageView()
    
    var stackView = UIStackView()
    
    let screenSize = UIScreen.main.bounds
    
    var message : String? {
        get { return label.text }
        set { label.text = newValue }
    }

    var image : UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0, green: 0.4616597415, blue: 1, alpha: 1)
        layer.cornerRadius = 10
        initSubView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        initSubView()
    }
    
    func initSubView(){
        
        //let stackView = UIStackView(frame: bounds)
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.frame = bounds.insetBy(dx: 20, dy: 20)
        
        //print(label.text)
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 30))
        imageView.clipsToBounds = true
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        
        addSubview(stackView)
    }
}
