//
//  LaunchScreenSwiftUI.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI

struct LaunchScreenSwiftUI: View {
    var signUpButtonCallBack:(()->())?
    var loginButtonCallBack:(()->())?
    var body: some View {
        VStack {
            Image("inthegym_icon3")
                .resizable()
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                .shadow(radius: 10.0, x: 20, y: 10)
                .padding([.top], 50)
                .padding(.horizontal)
            
            Text("INTHEGYM")
                .font(Font.custom("Menlo-Bold", size: 60))
                .foregroundColor(Color(UIColor.lightColour))
                .padding([.top], 40)
            Text("Create and Share Workouts")
                .frame(maxWidth: .infinity)
                .font(Font.custom("Menlo-BoldItalic", size: 20))
                .foregroundColor(Color(UIColor.darkColour))
                .padding(.bottom, 40)
            
            Button {
                signUpButtonCallBack?()
            } label: {
                Text("SIGN UP")
                    .bold()
                    .padding(15)
                    .font(Font.custom("Menlo-Bold", size: 25))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.darkColour))
                    .cornerRadius(20)
            }
            .padding(.top, 40)
            .padding([.leading, .trailing], 20)
            
            
            HStack {
                Text("Already have account?")
                Button {
                    loginButtonCallBack?()
                } label: {
                    Text("Log In")
                        .bold()
                        .foregroundColor(Color(UIColor.darkColour))
                }
            }
        }
    }
}

struct LaunchScreenSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenSwiftUI()
    }
}
