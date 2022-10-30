//
//  JournalHomeView.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct JournalHomeView: View {
    
    @StateObject var viewModel = JournalHomeViewModel()
    
    var body: some View {
        List {
            
            Section {
                Button {
                    viewModel.addNewEntryAction()
                } label: {
                    Text("Add new journal entry")
                }
            }
            
            if !viewModel.todayEntry.isEmpty {
                Section {
                    ForEach(viewModel.todayEntry) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.date, format: .dateTime.day().month().year())
                                .foregroundColor(.secondary)
                                .font(.footnote.bold())
                            Text(entry.entry)
                                .foregroundColor(.primary)
                                .font(.body.weight(.medium))
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        }
                        .onTapGesture {
                            viewModel.selectedEntry = entry
                        }
                    }
                } header: {
                    Text("Today's Entries")
                }
            }
            
            Section {
                ForEach(viewModel.journalEntries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.date, format: .dateTime.day().month().year())
                            .foregroundColor(.secondary)
                            .font(.footnote.bold())
                        Text(entry.entry)
                            .foregroundColor(.primary)
                            .font(.body.weight(.medium))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                    .onTapGesture {
                        viewModel.selectedEntry = entry
                    }
                }
            } header: {
                Text("All Entries")
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingNewEntrySheet) {
            JournalEntryView { model in
                viewModel.newEntryAdded(model)
            }
        }
        .fullScreenCover(item: $viewModel.selectedEntry, content: { item in
            ViewJournalEntryView(entry: item)
        })
        .task {
            await viewModel.getJournalEntries()
        }
    }
}

struct JournalHomeView_Previews: PreviewProvider {
    static var previews: some View {
        JournalHomeView(viewModel: JournalHomeViewModel())
    }
}
