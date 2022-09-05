//
//  WellnessQuestionaireView.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct WellnessQuestionaireView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WellnessViewModel
    @State private var sleepAmount: Double = 8
    @State private var sleepQuality: SleepQuality = .good
    @State private var bodyFeeling: Int = 7
    @State private var mindFeeling: Int = 7
    @State private var happiness: Int = 7
    @State private var motivation: Int = 7
    @State private var status: WellnessStatus = .fresh
    var body: some View {
        NavigationView {
            List {
                Section("Sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...12, step: 0.5)
                    HStack {
                        Text("Sleep Quality")
                        Spacer()
                        Picker("Sleep Quality", selection: $sleepQuality) {
                            ForEach(SleepQuality.allCases, id: \.self) {
                                Text($0.title)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Body") {
                    QuestionView(number: $bodyFeeling, title: "Body", message: "How does the body feel?")
                }
                
                Section("Mind") {
                    QuestionView(number: $mindFeeling, title: "Mind", message: "How does the mind feel?")
                }
                
                Section("Happy") {
                    QuestionView(number: $happiness, title: "Happy", message: "How happy do you feel?")
                }
                
                Section("Motivation") {
                    QuestionView(number: $motivation, title: "motivated", message: "How motivated do you feel?")
                }
                Section {
                    Picker("Select Status", selection: $status) {
                        ForEach(WellnessStatus.allCases, id: \.self) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Status")
                } footer: {
                    Text("Select the status that best describes how you are feeling today. Be honest.")
                }
                Section("submit") {
                    Button {
                        let answersModel = WellnessAnswersModel(time: .now,
                                                                sleepAmount: sleepAmount,
                                                                sleepQuality: sleepQuality.rawValue,
                                                                bodyFeeling: bodyFeeling,
                                                                mindFeeling: mindFeeling,
                                                                happyFeeling: happiness,
                                                                motivationFeeling: motivation,
                                                                status: status)
                        Task {
                            await viewModel.generatedCurrentScore(from: answersModel)
                            dismiss()
                        }
//                        viewModel.generatedCurrentScore(from: answersModel)
//                        dismiss()
                    } label: {
                        Text("Submit Wellness Scores")
                    }
                }
            }
            .navigationTitle("Wellness Questions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.bold())
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
        }
        
    }
}

struct WellnessQuestionaireView_Previews: PreviewProvider {
    static var previews: some View {
        WellnessQuestionaireView(viewModel: WellnessViewModel())
    }
}

struct QuestionView: View {
    @Binding var number: Int
    var title: String
    var message: String
    var body: some View {
        VStack {
            Text(message)
            Picker(title, selection: $number) {
                ForEach(0..<11, id: \.self) { num in
                    Text(num, format: .number)
                }
            }
            .pickerStyle(.segmented)
            HStack {
                Text("bad")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                Text("great")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical)
    }
}

enum SleepQuality: Int, CaseIterable {
    case veryPoor = 1
    case poor = 2
    case ok = 3
    case good = 4
    case veryGood = 5
    
    var title: String {
        switch self {
        case .veryPoor: return "Very Poor"
        case .poor: return "Poor"
        case .ok: return "Ok"
        case .good: return "Good"
        case .veryGood: return "Very Good"
        }
    }
}


