//
//  PracticeTrackerListView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 03/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PracticeTrackerListView: View {
    var model: PracticeTrackerModel
    
    var body: some View {
        VStack {
            HStack {
                Text(Date(timeIntervalSince1970: model.date).getMonthYearFormat())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            HStack {
                Spacer()
                Text(model.overallRating, format: .number)
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(.darkColour))
                    .padding()
                Spacer()
            }
            HStack {
                VStack {
                    Text(model.technicalRating, format: .number)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Technical")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text(model.tacticalRating, format: .number)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Tactical")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text(model.physicalRating, format: .number)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Physical")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                VStack {
                    Text(model.mentalRating, format: .number)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Mental")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}
