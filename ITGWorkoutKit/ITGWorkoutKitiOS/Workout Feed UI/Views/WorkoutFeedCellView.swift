//
//  WorkoutFeedCellView.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 15/07/2024.
//

import SwiftUI
import ITGWorkoutKit

public struct WorkoutFeedCellView: View {
    
    let model: WorkoutFeedItemViewModel
    
    public var body: some View {
        VStack {
            Text(workoutTitle)
                .font(.title.weight(.medium))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .padding(.horizontal)
            
            Text("\(exerciseCount) exercises")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            Color(.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 4)
        }
    }
    
    public var workoutTitle: String {
        model.title
    }
    
    public var exerciseCount: String {
        model.exerciseCount
    }
}

#Preview {
    WorkoutFeedCellView(model: .init(id: UUID(), title: "a title", exerciseCount: "5"))
}
