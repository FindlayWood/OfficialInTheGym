//
//  ErrorPopover.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct ErrorPopover: View {
    
    @ObservedObject var viewModel: MyMeasurementsViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack(spacing: 8) {
                Text("Error!")
                    .font(.title.bold())
                    .foregroundColor(.red)
                Text("There was an error, please try again.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button("ok") {
                    viewModel.error = nil
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
