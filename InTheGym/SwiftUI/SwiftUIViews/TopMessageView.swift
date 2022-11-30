//
//  TopMessageView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 30/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct TopMessageView: View {
    var timeDisplayed: Int?
    var text: String
    var dismiss: (() -> ())?
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(text)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        
                    if timeDisplayed == nil {
                        Button {
                            dismiss?()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.darkColour))
                .cornerRadius(8)
                Spacer()
            }
            .padding()
        }
        .onAppear {
            if let timeDisplayed  {
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(timeDisplayed)) {
                    dismiss?()
                }
            }
        }
    }
}

struct TopMessageView_Previews: PreviewProvider {
    static var previews: some View {
        TopMessageView(text: "Top Message", dismiss: {})
    }
}
