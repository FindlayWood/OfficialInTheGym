//
//  MeasurementsSubview.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct MeasurementSubview: View {
    
    var placeholder: String
    var units: String
    @Binding var enteredText: String
    
    var body: some View {
        VStack() {
            Text(placeholder)
                .font(.largeTitle.bold())
                .padding()
            TextField("enter \(placeholder.lowercased()) \(units)", text: $enteredText)
                .font(.title.bold())
                .foregroundColor(.primary)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
            Text("\(enteredText)\(units)")
                .font(.title.bold())
                .padding()
        }
    }
}
