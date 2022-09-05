//
//  WellnessView.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct WellnessMainView: View {
    
    @State private var isShowingQuestionaire = false
    @StateObject var viewModel = WellnessViewModel()
    
    var body: some View {
        List {
            Section("Todays Score") {
                if viewModel.isLoading {
                    ProgressView()
                } else if let currentScore = viewModel.currentScore {
                    WellnessStatusRowView(model: currentScore)
                } else {
                    Button {
                        isShowingQuestionaire = true
                    } label: {
                        Text("Add Today's Wellness Score")
                    }
                }
            }
            Section("Previous Scores") {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ForEach(viewModel.previousScores) { model in
                        WellnessHistoryRowView(model: model)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingQuestionaire) {
            WellnessQuestionaireView(viewModel: viewModel)
        }
        .task {
            await viewModel.getWellnessScores()
        }
    }
}

struct CurrentWellnessView: View {
    var score: Int
    var body: some View {
        Text("todays score \(score)")
    }
}

struct WellnessQuestionaire: View {
    var body: some View {
        Text("Wellness questions")
    }
}

