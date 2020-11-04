//
//  ViewDesign.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit

@IBDesignable
class ViewDesign: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //for border colour
    @IBInspectable public var borderColor : UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    //for border width
    @IBInspectable public var borderWidth : CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    //for corner radius
    @IBInspectable public var cornerRadius : CGFloat = 0.0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    //for shadow opacity
    @IBInspectable public var shadowOpacity : CGFloat = 0.0{
        didSet{
            self.layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    //for shadow color
    @IBInspectable public var shadowColor : UIColor = UIColor.clear{
        didSet{
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    //for shadow radius
    @IBInspectable public var shadowRadius : CGFloat = 0.0{
        didSet{
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    //for shadow offset
    @IBInspectable public var shadowOffsetY : CGFloat = 0.0{
        didSet{
            self.layer.shadowOffset.height = shadowOffsetY
        }
    }
    
    
}
