//
//  SignUpNameView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 04/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SignUpNameView: View {
    @EnvironmentObject var viewModel: SignUpViewModel
    var body: some View {
        VStack {
            CustomTextField(text: $viewModel.firstName, placeholder: "first name...")
            CustomTextField(text: $viewModel.lastName, placeholder: "last name...")
            Button {
                
            } label: {
                Text("Next")
            }
        }
    }
}

struct SignUpNameView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpNameView()
    }
}
