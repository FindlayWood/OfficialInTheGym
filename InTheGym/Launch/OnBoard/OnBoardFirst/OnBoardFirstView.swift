//
//  OnBoardFirstView.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct OnBoardFirstView: View {
    var body: some View {
        VStack {
            Image("logo_icon_transparent")
                .resizable()
                .frame(width: 300, height: 300)
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(.darkColour))
            Text("Welcome to InTheGym \n Powering Elite Athletes")
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            Text("swipe for more")
                .font(.body)
                .fontWeight(.light)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}

struct OnBoardFirstView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardFirstView()
    }
}
