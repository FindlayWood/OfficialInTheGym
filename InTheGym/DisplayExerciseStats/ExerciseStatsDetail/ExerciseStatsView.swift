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
        ScrollView {
            VStack {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(colors: [Color(.darkColour), Color(.lightColour)], center: .center, startRadius: 50, endRadius: 150)
                        )
                        .frame(width: 250, height: 250)
                        .shadow(radius: 4)
                    HStack(alignment: .center) {
                        Text(viewModel.statsModel.repsCompletedString)
                            .font(.system(size: 80))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Text("reps")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(EdgeInsets(top: 32, leading: 8, bottom: 32, trailing: 8))
                }
                .padding(.bottom)
                
                ExerciseStatSubView(title: "Max Weight:", value: viewModel.statsModel.maxWeightString)
                ExerciseStatSubView(title: "Total Weight:", value: viewModel.statsModel.totalWeightString)
                ExerciseStatSubView(title: "Average Weight:", value: viewModel.statsModel.averageWeightString)
                ExerciseStatSubView(title: "Average RPE:", value: viewModel.statsModel.averageRPEString)
                    .padding(.bottom)
                MainButton(text: "View Max History") {
                    viewModel.viewMax.send(())
                }
            }
            .padding(.horizontal)
        }
        .edgesIgnoringSafeArea([.top, .leading, .trailing])
        .background(
            LinearGradient(colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground), Color(.lightColour)], startPoint: .top, endPoint: .bottom)
        )
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
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 2)
        )
        .shadow(radius: 4)
    }
}
