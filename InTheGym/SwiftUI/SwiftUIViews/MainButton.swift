//
//  MainButton.swift
//  InTheGym
//
//  Created by Findlay-Personal on 21/12/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct MainButton: View {
    var text: String
    var disabled: Bool = false
    var action: () -> ()
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .padding()
                .font(.headline)
                .foregroundColor(.white.opacity(disabled ? 0.3 : 1.0))
                .frame(maxWidth: .infinity)
                .background(Color(.darkColour).opacity(disabled ? 0.3 : 1.0))
                .clipShape(Capsule())
                .shadow(radius: 4)
        }
        .disabled(disabled)
    }
}

struct MainButton_Previews: PreviewProvider {
    static var previews: some View {
        MainButton(text: "test", action: {
            
        })
    }
}
