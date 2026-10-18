//
//  OnBoardSecondView.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct OnBoardSecondView: View {
    var body: some View {
        VStack {
            Image(uiImage: UIImage.legacyIcon("figure.strengthtraining.traditional"))
                .resizable()
                .frame(width: 100, height: 100)
            Text("Create and Share Workouts")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(.darkColour))
            Text("Create, share and save workouts with huge customisation.")
                .font(.body)
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
    }
}

struct OnBoardSecondView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardSecondView()
    }
}
