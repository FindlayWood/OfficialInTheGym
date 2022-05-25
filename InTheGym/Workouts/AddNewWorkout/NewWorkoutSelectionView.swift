//
//  NewWorkoutSelectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct NewWorkoutSelectionView: View {
    
    var viewModel: NewWorkoutSelectionViewModel
    
    var body: some View {
        VStack {
            Spacer()
            Button {
                viewModel.selectedOption.send(.workout)
            } label: {
                VStack (alignment: .leading) {
                    Text("Workout Builder")
                        .font(.title)
                        .foregroundColor(Color(.darkColour))
                        .fontWeight(.bold)
                    Text("Build a workout with all options available. Choose to save this workout for later use. This workout will be added to your workouts list.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            Button {
                viewModel.selectedOption.send(.liveWorkout)
            } label: {
                VStack (alignment: .leading) {
                    Text("Live Workout Builder")
                        .font(.title)
                        .foregroundColor(Color(.darkColour))
                        .fontWeight(.bold)
                    Text("Build a workout as you do it. Edit exercises, sets and reps as you workout. (Live workouts can't add Circuits, AMRAPs or EMOMS and cant't be saved)")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            Button {
                viewModel.selectedOption.send(.savedWorkout)
            } label: {
                VStack (alignment: .leading) {
                    Text("Saved Workout Builder")
                        .font(.title)
                        .foregroundColor(Color(.darkColour))
                        .fontWeight(.bold)
                    Text("Build a saved workout with all options available. This workout will be added to your saved workouts list.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.all)
    }
}

struct NewWorkoutSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NewWorkoutSelectionView(viewModel: NewWorkoutSelectionViewModel())
    }
}
