//
//  ExerciseStatsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct ExerciseStatsView: View {
    var viewModel: ExerciseStatsDetailViewModel
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(viewModel.statsModel.repsCompletedString)
                    .font(.system(size: 80))
                    .fontWeight(.heavy)
                Text("reps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }.padding(EdgeInsets(top: 32, leading: 8, bottom: 32, trailing: 8))
            HStack {
                ExerciseStatSubView(title: "Max Weight ", value: viewModel.statsModel.maxWeightString)
                    .padding()
                ExerciseStatSubView(title: "Total Weight", value: viewModel.statsModel.totalWeightString)
                    .padding()
            }
            HStack {
                ExerciseStatSubView(title: "Average Weight", value: viewModel.statsModel.averageWeightString)
                    .padding()
                ExerciseStatSubView(title: "Average RPE", value: viewModel.statsModel.averageRPEString)
                    .padding()
            }
            Button {
                viewModel.viewMax.send(())
            } label: {
                Text("View Max History")
                    .font(.headline)
                    .foregroundColor(Color(.lightColour))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .padding()
                    
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color(.secondarySystemBackground))
    }
}

struct ExerciseStatsView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseStatsView(viewModel: ExerciseStatsDetailViewModel())
    }
}

struct ExerciseStatSubView: View {
    var title: String
    var value: String
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 2)
        )
    }
}
