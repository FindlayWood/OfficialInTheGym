//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import SwiftUI

struct ExerciseSelectionView: View {
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.exercises, id: \.self) { model in
                HStack {
                    Text(model)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        viewModel.name = model
                        viewModel.page += 1
                    }
                }
            }
        }
    }
}

struct ExerciseSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSelectionView(viewModel: ExerciseCreationHomeViewModel(workoutCreation: PreviewWorkoutCreation()))
    }
}
