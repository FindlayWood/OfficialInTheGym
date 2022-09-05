//
//  InjuryTrackerView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct InjuryTrackerView: View {
    @StateObject var viewModel = InjuryTrackerViewModel()
    @State private var isShowingSheet = false
    
    var body: some View {
        List {
            if viewModel.currentInjury != nil || viewModel.isLoading {
                Section("Current Injury") {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        if let model = viewModel.currentInjury {
                            VStack(alignment: .leading) {
                                InjuryRow(model: model)
                                HStack(spacing: 0) {
                                    Text("Recovery time: ")
                                    Text((model.recoveryTime - Calendar.current.numberOfDaysBetween(model.dateOccured, and: .now)), format: .number)
                                    Text("days")
                                }
                                
                                if !model.recovered {
                                    Button {
                                        print("recovered")
                                    } label: {
                                        Text("Mark as Recovered")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Section {
                Button {
                    isShowingSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add new Injury")
                    }
                }
            }
            
            Section("Injury History") {
                ForEach(viewModel.previousInjuries) { model in
                    InjuryRow(model: model)
                }
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            AddNewInjuryView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadModels()
        }
    }
}

struct InjuryTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        InjuryTrackerView()
    }
}


struct InjuryRow: View {
    var model: InjuryModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.bodyPart)
                .font(.headline)
            Text(model.dateOccured, format: .dateTime.day().month().year())
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
