//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 11/12/2023.
//

import SwiftUI

struct MainButton: View {
    
    let text: String
    let disabled: Bool
    var overlayImage: String?
    var action: () -> ()
    
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                
                Text(text)
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkColour).opacity(disabled ? 0.3 : 1))
                    .clipShape(Capsule())
                    .shadow(radius: disabled ? 0 : 2, y: 2)
                
                if let overlayImage {
                    HStack {
                        Spacer()
                        Image(systemName: overlayImage)
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MainButton(text: "Example", disabled: false, overlayImage: "qrcode.viewfinder", action: {})
}
