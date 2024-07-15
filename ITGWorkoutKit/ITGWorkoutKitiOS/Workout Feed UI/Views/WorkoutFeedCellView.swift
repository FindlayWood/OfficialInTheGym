//
//  WorkoutFeedCellView.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 15/07/2024.
//

import SwiftUI
import ITGWorkoutKit

struct WorkoutFeedCellView: View {
    
    let model: WorkoutFeedItemViewModel
    
    var body: some View {
        VStack {
            Text(model.title)
                .font(.title.weight(.medium))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .padding(.horizontal)
            
            Text("\(model.exerciseCount) exercises")
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
}

#Preview {
    WorkoutFeedCellView(model: .init(title: "a title", exerciseCount: "5"))
}
