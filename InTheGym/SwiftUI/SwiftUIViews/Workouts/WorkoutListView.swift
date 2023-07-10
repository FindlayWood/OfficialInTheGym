//
//  WorkoutListView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 18/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct WorkoutListView: View {
    var model: WorkoutModel
    var body: some View {
        VStack(spacing: 0) {
            Text(model.title)
                .font(.title2.bold())
                .foregroundColor(Color(.darkColour))
                .minimumScaleFactor(0.1)
                .lineLimit(1)
            Rectangle()
                .fill(.black)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            HStack {
                if model.completed {
                    Text("COMPLETED")
                        .font(.callout.bold())
                        .foregroundColor(Color(.completedColour))
                    if let date = model.startTime {
                        Text(Date(timeIntervalSince1970: date).getWorkoutFormat())
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                } else if model.liveWorkout ?? false {
                    Text("LIVE")
                        .font(.callout)
                        .foregroundColor(Color(.liveColour))
                        .fontWeight(.semibold)
                } else if model.startTime != nil {
                    Text("IN PROGRESS")
                        .font(.callout)
                        .foregroundColor(Color(.liveColour))
                        .fontWeight(.semibold)
                } else {
                    Text("NOT STARTED")
                        .font(.callout)
                        .foregroundColor(Color(.notStartedColour))
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 8)
            WorkoutFiguresView(model: model)
                .padding(.top)
            if let clipData = model.clipData {
                if clipData.count > 0 {
                    WorkoutClipThumbnailView(models: clipData)
                }
            }
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

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView(model: WorkoutModel(liveModel: .init(id: "", title: "Wednesday - Session", creatorID: "", assignedTo: "", isPrivate: false, completed: true, liveWorkout: false, startTime: 0)))
    }
}
