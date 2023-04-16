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
                .frame(width: 240, height: 128)
            
            Spacer()
            Text("UALLAS")
                .font(.body.italic())
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct LaunchPageView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchPageView()
    }
}
