//
//  CustomTextField.swift
//  InTheGym
//
//  Created by Findlay-Personal on 04/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var image: String?
    var placeholder: String
    var body: some View {
        HStack {
            if let image {
                Image(systemName: image)
                    .foregroundColor(Color(.darkColour))
            }
            
            TextField(placeholder, text: $text)
                .tint(Color(.darkColour))
        }
        .padding()
        .background(.white)
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(text: .constant(""), placeholder: "enter...")
    }
}
