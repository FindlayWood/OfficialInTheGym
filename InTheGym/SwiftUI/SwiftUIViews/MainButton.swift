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
    var action: () -> ()
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .padding()
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color(.darkColour))
                .clipShape(Capsule())
                .shadow(radius: 4)
        }
    }
}

struct MainButton_Previews: PreviewProvider {
    static var previews: some View {
        MainButton(text: "test", action: {
            
        })
    }
}
