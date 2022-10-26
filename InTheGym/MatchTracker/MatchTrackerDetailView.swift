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
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                HStack {
                    Text("Ratings")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Spacer()
                }
                .padding([.horizontal, .top])
                HStack {
                    Spacer()
                    Text(model.overallRating, format: .number)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color(.darkColour))
                    Spacer()
                }
                Text("Overall Match Rating")
                    .font(.footnote)
                    .foregroundColor(Color(.darkColour))
                Text(Date(timeIntervalSince1970: model.date).getMonthYearFormat())
                    .font(.caption)
                    .foregroundColor(.secondary)
                LazyVGrid(columns: columns) {
                    VStack {
                        Text(model.technicalRating, format: .number)
                        Text("Technical Rating")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    VStack {
                        Text(model.tacticalRating, format: .number)
                        Text("Tactical Rating")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    VStack {
                        Text(model.physicalRating, format: .number)
                        Text("Physical Rating")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    VStack {
                        Text(model.mentalRating, format: .number)
                        Text("Mental Rating")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Workload Data")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("This is data at the time of entering match details")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding([.horizontal, .top])
                LazyVGrid(columns: columns) {
                    if let workloadRatio = model.workloadRatio {
                        VStack {
                            Text(workloadRatio.acwr.rounded(toPlaces: 1), format: .number)
                            Text("ACWR")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    if let workloadRatio = model.workloadRatio {
                        VStack {
                            Text(workloadRatio.acuteLoad, format: .number)
                            Text("Acute Load")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    if let workloadRatio = model.workloadRatio {
                        VStack {
                            Text(workloadRatio.freshnessIndex.rounded(toPlaces: 1), format: .number)
                            Text("Freshness Index")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    if let workloadRatio = model.workloadRatio {
                        VStack {
                            Text(workloadRatio.monotony.rounded(toPlaces: 2), format: .number)
                            Text("Monotony")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    if let workloadRatio = model.workloadRatio {
                        VStack {
                            Text(workloadRatio.trainingStrain.rounded(toPlaces: 2), format: .number)
                            Text("Training Strain")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    if let wellness = model.wellnessStatus {
                        VStack {
                            Text(wellness.status.title)
                            Text("Wellness Status")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    if let cmj = model.cmjModel {
                        VStack {
                            Text(cmj.fatigueLevel.title)
                            Text("CMJ Fatigue Level")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    if let workload = model.mostRecentWorkload {
                        VStack {
                            Text(Date(timeIntervalSince1970: workload.endTime).getMonthYearFormat())
                            Text("Most Recent Workload")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                HStack {
                    Text("Notes")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Spacer()
                }
                .padding([.horizontal, .top])
                Text(model.notes)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
        }
    }
}
