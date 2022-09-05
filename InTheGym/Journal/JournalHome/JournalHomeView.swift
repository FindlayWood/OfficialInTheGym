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
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.hasEnteredToday {
                    if let entry = viewModel.todayEntry {
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
                    }
                } else {
                    Button {
                        viewModel.isShowingNewEntrySheet = true
                    } label: {
                        Text("Add today's journal entry")
                    }
                }
            } header: {
                Text("Today's Entry")
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
                }
            } header: {
                Text("Previous Entries")
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingNewEntrySheet) {
            JournalEntryView()
        }
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
