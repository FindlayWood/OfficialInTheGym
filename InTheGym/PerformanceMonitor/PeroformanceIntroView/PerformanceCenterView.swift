//
//  PerformanceCenterView.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PerformanceCenterView: View {
    var viewModel: PerformanceIntroViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Image(uiImage: UIImage(named: "monitor_icon")!)
                    .resizable()
                    .frame(width: 100, height: 100)
                Text("Welcome to the performance center. Here you will have access to several performance monitoring tools. Workload, vertical jump, CMJ and more...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                ForEach(PerformanceIntroOptions.allCases, id: \.self) { option in
                    Button {
                        viewModel.action.send(option)
                    } label: {
                        PerformanceCenterOptionView(option: option)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Performance Center")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("dismiss")
                } label: {
                    Text("Dismiss")
                        .bold()
                        .foregroundColor(Color(.darkColour))
                }
            }
        }
    }
}

struct PerformanceCenterView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceCenterView(viewModel: PerformanceIntroViewModel())
    }
}
