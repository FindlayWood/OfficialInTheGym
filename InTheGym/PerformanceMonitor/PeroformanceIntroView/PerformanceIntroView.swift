//
//  PerformanceIntroView.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
//

import SwiftUI

struct PerformanceIntroView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Image("monitor_icon")
                .resizable()
                .frame(width: 100, height: 100)
            Text("Welcome to the Performance Monitor")
                .foregroundColor(.primary)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Here you will find some statistics related to all the workouts you have completed on this app. Data has been calculated to help you get the most out of your training and keep you healthy.")
                .foregroundColor(.secondary)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .resizable()
                    .foregroundColor(Color(.darkColour))
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Workload")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Check out your workload over the last 7 days, 14 days or 28 days.")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .fontWeight(.medium )
                }
            }
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .resizable()
                    .foregroundColor(Color(.darkColour))
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Acute Chronic Workload Ratio")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Check out your acwr and see how you compare with the optimal ratio and peak performance.")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .fontWeight(.medium )
                }
            }
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .resizable()
                    .foregroundColor(Color(.darkColour))
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Training Strain")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Check out your training strain and see if you are putting too much stress on your body.")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .fontWeight(.medium )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 2)
        )
    }
}
