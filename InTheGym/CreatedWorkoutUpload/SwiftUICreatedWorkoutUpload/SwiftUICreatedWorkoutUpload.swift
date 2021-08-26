//
//  SwiftUICreatedWorkoutUpload.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct SwiftUICreatedWorkoutUpload: View {
    var body: some View {
        VStack(alignment: .leading, spacing: nil, content: {
            Color(UIColor.lightColour)
                .frame(width: Constants.screenSize.width, height: 200, alignment: .center)
                .opacity(0.8)
            Text("Upload Workout")
                .foregroundColor(.white)
                .font(Font.system(size: 45, weight: .bold, design: .default))
                .offset(x: 0, y: -100)
            SwiftUIWorkoutView()
                .frame(width: Constants.screenSize.width - 20, height: 150, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
                .offset(x: 0, y: -120)
                .padding(.leading, 10)

        })
    }
}


@available(iOS 13.0, *)
struct SwiftUICreatedWorkoutUpload_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUICreatedWorkoutUpload()
    }
}
