//
//  OnBoardThirdView.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI
import Combine

struct OnBoardThirdView: View {
    var startedButtonAction = PassthroughSubject<Void,Never>()
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("clip_icon")
                    .resizable()
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("Clips")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.darkColour))
                    Text("Record, save and upload short video clips attached to exercises.")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            HStack {
                Image("monitor_icon")
                    .resizable()
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("Monitor Performance")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.darkColour))
                    Text("Monitor your performance with the optimal ratio, record RPE for exercises and sessions, monitor workload, training strain and more.")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            Button {
                startedButtonAction.send(())
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(.darkColour))
            .cornerRadius(8)
        }
        .padding()
    }
}

struct OnBoardThirdView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardThirdView()
    }
}
