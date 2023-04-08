//
//  LaunchPageView.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct LaunchPageView: View {
    
    var body: some View {
        
        VStack {
            Spacer()
            
            Image("inthegym_icon3")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
    }
}
