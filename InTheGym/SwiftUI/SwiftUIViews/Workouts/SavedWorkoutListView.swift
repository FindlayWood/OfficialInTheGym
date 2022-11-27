//
//  SavedWorkoutListView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 26/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SavedWorkoutListView: View {
    var model: SavedWorkoutModel
    var body: some View {
        VStack(spacing: 0) {
            Text(model.title)
                .font(.title.bold())
                .foregroundColor(Color(.darkColour))
            Rectangle()
                .fill(.black)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            Text("Saved")
                .foregroundColor(Color(.lightColour))
                .fontWeight(.semibold)
            VStack(spacing: 0) {
                Text(model.exercises?.count ?? 0, format: .number)
                    .font(.title3)
                    .foregroundColor(.primary)
                Image("dumbbell_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 1)
        )
    }
}
