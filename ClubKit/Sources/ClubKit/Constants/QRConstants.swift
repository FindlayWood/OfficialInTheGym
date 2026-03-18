//
//  File.swift
//  
//
//  Created by Findlay Wood on 03/12/2023.
//

import Foundation


enum QRConstants {
    
    static let startCode: String = "itgqrcodestart"
    static let separatingCode = "$"
    static let endCode: String = "itgqrcodeend"
    static let simulatedData = startCode + separatingCode + "userid" + separatingCode + "display name" + separatingCode + "username" + separatingCode + endCode
}
