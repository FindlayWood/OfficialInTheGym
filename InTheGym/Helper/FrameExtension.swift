//
//  FrameExtension.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

extension UIViewController {
    func getFullViewableFrame() -> CGRect {
        return CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
    }
    func getViewableFrameWithBottomSafeArea() -> CGRect {
        return CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
    }
    func getFullScreenFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
}
