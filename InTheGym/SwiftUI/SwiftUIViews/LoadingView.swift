//
//  LoadingView.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    var animation: Animation {
        Animation.linear(duration: 2)
        .repeatForever(autoreverses: false)
    }
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack {
                Circle()
                    .trim(from: 0.2, to: 1)
                    .stroke(Color(.darkColour), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(animation)
                    .padding(50)
                    .onAppear {
                        isAnimating = true
                    }
            }
            .background(Color.white)
            .cornerRadius(8)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
