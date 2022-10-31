//
//  InjuryDetailView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 31/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct InjuryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: InjuryTrackerViewModel
    @State var injuryModel: InjuryModel
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(injuryModel.bodyPart)
                        .font(.headline)
                        .foregroundColor(.primary)
                } header: {
                    Text("Injured Body Part")
                }
                
                Section {
                    Text("Start Date: \(injuryModel.dateOccured, format: .dateTime.day().month().year())")
                    Text("Estimated Recovery Time: \(injuryModel.recoveryTime) days")
                    if let estimatedRecoveryDate {
                        Text("Estimated Recovery Date: \(estimatedRecoveryDate, format: .dateTime.day().month().year())")
                    }
                } header: {
                    Text("Timeframe")
                }
                
                Section {
                    Text(injuryModel.severity.title)
                } header: {
                    Text("Severity")
                }
                
                if !injuryModel.recovered {
                    Section {
                        Button {
                            Task {
                                await viewModel.markInjuryAsRecovered(injuryModel)
                                injuryModel.recovered = true
                            }
                        } label: {
                            Text("Mark as Recovered")
                        }
                    } footer: {
                        Text("If you have recovered from this injury before the estimated recovery date, you can mark this injury as recovered. This lets your coaches know you arer fit and gives you correct data for other calculations throughout InTheGym.")
                    }
                }
            }
            .navigationTitle("Injury Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .font(.body.bold())
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
        }
    }
    
    var estimatedRecoveryDate: Date? {
        let startDate = injuryModel.dateOccured
        var dateComponent = DateComponents()
        dateComponent.day = injuryModel.recoveryTime
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: startDate)
        return futureDate
    }
}
