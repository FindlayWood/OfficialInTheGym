//
//  ViewJournalEntryView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 30/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct ViewJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    
    var entry: JournalEntryModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(entry.entry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            }
            .navigationTitle(entry.date.getDayMonthFormat())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .foregroundColor(Color(.darkColour))
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}
