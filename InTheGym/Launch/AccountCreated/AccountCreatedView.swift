//
//  AccountCreatedView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 15/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct AccountCreatedView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Account Created")
                .font(.title.bold())
            Image(systemName: "person.crop.circle.fill.badge.checkmark")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color(.darkColour))
                .padding()
            Text("Your account has been created and verified! You are all ready to start using InTheGym!")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
            
            Spacer()
            MainButton(text: "To the App") {
                UserObserver.shared.toTheApp()
            } 
        }
        .padding()
    }
}

struct AccountCreatedView_Previews: PreviewProvider {
    static var previews: some View {
        AccountCreatedView()
    }
}
