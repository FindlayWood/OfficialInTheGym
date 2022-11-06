//
//  CustomSecureTextField.swift
//  InTheGym
//
//  Created by Findlay-Personal on 06/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct CustomSecureTextField: View {
    @Binding var text: String
    @Binding var state: SignUpValidState
    @State private var showing: Bool = false
    var placeholder: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color(.darkColour))
                    
                    if showing {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                    Button {
                        showing.toggle()
                    } label: {
                        Image(systemName: showing ? "eye" : "eye.slash")
                            .foregroundColor(.black)
                    }
                }
                if state == .inValidInfo {
                    Text("Password must be at least 6 characters.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
        }
        .padding()
        .background(.white)
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}

struct CustomSecureTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomSecureTextField(text: .constant(""), state: .constant(.inValidInfo), placeholder: "test...")
    }
}
