//
//  PurchaseSuccessSubview.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import SwiftUI

struct PurchaseSuccessSubview: View {
    var action: (() -> ())
    var body: some View {
        VStack {
            Text("Great!")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.primary)
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(Color(.premiumColour))
                .padding()
            Text("You are now subscribed to InTheGym Pro")
                .foregroundStyle(Color.primary)
            
            Button {
                action()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        Color(.premiumColour)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.5), radius: 2, y: 2)
                    }
            }
            .padding()
        }
    }
}

#Preview {
    PurchaseSuccessSubview(action: {})
}
