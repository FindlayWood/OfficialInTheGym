//
//  ExerciseStatsListView.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct ExerciseStatsListView: View {
    
    @ObservedObject var viewModel: DisplayExerciseStatsViewModel
    
    var body: some View {
        VStack {
            SearchBar(searchText: $viewModel.searchText, placeholder: "search exercises")
            List {
                ForEach(viewModel.filteredModels, id: \.self) { model in
                    ExerciseStatsListRow(model: model)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.exerciseSelected(model)
                        }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.grouped)
        }
        
    }
}

struct ExerciseStatsListView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseStatsListView(viewModel: DisplayExerciseStatsViewModel())
    }
}
