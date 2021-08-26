//
//  SwiftUICard.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI

protocol SwiftUICardContent {
    var imageName: String {get}
    var title: String {get}
}

@available(iOS 13.0, *)
struct SwiftUICard: View {
    
    typealias Content = SwiftUICardContent
    
    let content: Content
    
    var body: some View {
        VStack(alignment: .center, spacing: 8, content: {
            Spacer()
            
            Image(content.imageName)
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            Text(content.title)
                .font(Font.system(size: 25, weight: .medium, design: .default))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        })
    }
}


//struct SwiftUICard_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUICard()
//    }
//}
