//
//  CustomTextFieldWithCheck.swift
//  InTheGym
//
//  Created by Findlay-Personal on 06/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct CustomTextFieldWithCheck: View {
    @Binding var text: String
    @Binding var state: SignUpValidState
    var errorMessage: String
    var image: String?
    var placeholder: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if let image {
                        Image(systemName: image)
                            .foregroundColor(Color(.darkColour))
                    }
                    TextField(placeholder, text: $text)
                        .tint(Color(.darkColour))
                    switch state {
                    case .notEnoughInfo:
                        EmptyView()
                    case .inValidInfo:
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                    case .valid:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(.darkColour))
                    case .checking:
                        ProgressView()
                            .foregroundColor(Color(.darkColour))
                    }
                }
                if state == .inValidInfo {
                    Text(errorMessage)
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

struct CustomTextFieldWithCheck_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextFieldWithCheck(text: .constant(""), state: .constant(.valid), errorMessage: "Error", placeholder: "test...")
    }
}
