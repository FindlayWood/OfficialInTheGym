//
//  SwiftUIWorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct SwiftUIWorkoutView: View {
    
    //@State private var workout: WorkoutDelegate
    
    var body: some View {
        Color(UIColor.offWhiteColour)
            .overlay(
                VStack(alignment: .leading, spacing: nil, content: {
                    Text("Workout Title")
                        .font(Font.system(size: 22, weight: .bold, design: .monospaced))
                        .padding(.bottom, 10)
                    HStack(alignment: .center, spacing: 5, content: {
                        Image("coach_icon")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .leading)
                        Text("Creator Username")
                            .font(.subheadline)
                    }).padding(.leading, 15)
                    HStack(alignment: .center, spacing: 5, content: {
                        Image("dumbbell_icon")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .leading)
                        Text("7")
                            .font(.subheadline)
                    }).padding(.leading, 15)
                }).frame(alignment: .leading)
            ).frame(alignment: .leading)
    }
}

@available(iOS 13.0, *)
struct SwiftUIWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIWorkoutView()
    }
}
