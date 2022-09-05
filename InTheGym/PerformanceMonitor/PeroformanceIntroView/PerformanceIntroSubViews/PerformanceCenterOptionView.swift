//
//  PerformanceCenterOptionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PerformanceCenterOptionView: View {
    var option: PerformanceIntroOptions
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(uiImage: option.image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .tint(Color(.darkColour))
                Text(option.title)
                    .font(.title2.bold())
                    .foregroundColor(Color(.darkColour))
                Spacer()
            }
            Text(option.message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

struct PerformanceCenterOptionView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceCenterOptionView(option: .workload)
    }
}
