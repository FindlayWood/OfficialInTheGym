//
//  LoadingView.swift
//
//
//  Created by Findlay Wood on 14/02/2024.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var colour: UIColor
    
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
                    .stroke(Color(colour), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(animation, value: isAnimating)
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

#Preview {
    LoadingView(colour: .darkColour)
}
