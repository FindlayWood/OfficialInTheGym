//
//  ResetPasswordView.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @State private var email: String = ""
     
    var body: some View {
        VStack {
            TextField("email", text: $email)
            
            Button {
                
            } label: {
                Text("Send Email")
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
