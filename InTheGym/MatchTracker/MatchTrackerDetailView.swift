//
//  MatchTrackerDetailView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct MatchTrackerDetailView: View {
    var model: MatchTrackerModel
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(model.overallRating, format: .number)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(.darkColour))
                Spacer()
            }
            Text(Date(timeIntervalSince1970: model.date).getMonthYearFormat())
                .font(.caption)
                .foregroundColor(.secondary)
            LazyVGrid(columns: columns) {
                VStack {
                    Text(model.technicalRating, format: .number)
                    Text("Technical Rating")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 4)
                VStack {
                    Text(model.tacticalRating, format: .number)
                    Text("Tactical Rating")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }.padding()
                    .background(Color.white)
                    .shadow(radius: 4)
                VStack {
                    Text(model.physicalRating, format: .number)
                    Text("Physical Rating")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }.padding()
                    .background(Color.white)
                    .shadow(radius: 4)
                VStack {
                    Text(model.mentalRating, format: .number)
                    Text("Mental Rating")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }.padding()
                    .background(Color.white)
                    .shadow(radius: 4)
                if let workloadRatio = model.workloadRatio {
                    VStack {
                        Text(workloadRatio.acwr, format: .number)
                        Text("ACWR")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }.padding()
                        .background(Color.white)
                        .shadow(radius: 4)
                }
                if let cmj = model.cmjModel {
                    VStack {
                        Text(cmj.fatigueLevel.title)
                        Text("Fatigue Level")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(cmj.fatigueLevel.message)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }.padding()
                        .background(Color.white)
                        .shadow(radius: 4)
                }
                if let wellness = model.wellnessStatus {
                    VStack {
                        Text(wellness.status.title)
                        Text("Wellness Status")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }.padding()
                        .background(Color.white)
                        .shadow(radius: 4)
                }
                if let workload = model.mostRecentWorkload {
                    VStack {
                        Text(Date(timeIntervalSince1970: workload.endTime).getMonthYearFormat())
                        Text("Most Recent Workload")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(radius: 4)
                }
            }
        }
    }
}
