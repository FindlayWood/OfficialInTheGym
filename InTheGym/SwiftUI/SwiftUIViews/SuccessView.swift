//
//  SuccessView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct SuccessView: View {
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color(.darkColour))
                    .padding(50)
            }
            .background(Color.white)
            .cornerRadius(8)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView()
    }
}
