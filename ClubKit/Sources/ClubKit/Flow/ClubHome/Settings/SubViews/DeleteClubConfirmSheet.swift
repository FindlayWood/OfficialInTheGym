//
//  DeleteClubConfirmSheet.swift
//
//
//  Created by Findlay Wood on 14/02/2024.
//

import SwiftUI

struct DeleteClubConfirmSheet: View {
    
    @ObservedObject var viewModel: ClubSettingsViewModel
    
    @State private var text: String = ""
    @State private var showFinalWarning: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Divider()
                    Text("Are you sure you want to delete this club? This action cannot be undone and all members will lose access to this club and all of it's data immediately. If you wish to delete this club please confirm by typing the name of the club in the box below and then clicking on the confirm delete button.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .padding(.bottom)
                    
                    Text(viewModel.clubModel.clubName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .padding()
                    
                    
                    VStack {
                        TextField("enter club name", text: $text)
                            .tint(Color(.darkColour))
                            .padding()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.darkColour), lineWidth: 2)
                    )
                    .padding()
                    
                    Spacer()
                    
                    MainButton(text: "Confirm Delete", disabled: text != viewModel.clubModel.clubName) {
                        showFinalWarning.toggle()
                    }
                }
                .padding()
                .navigationTitle("Confirm Delete")
                .navigationBarTitleDisplayMode(.inline)
                .alert("Final Warning", isPresented: $showFinalWarning) {
                    Button("cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) { viewModel.deleteClub() }
                }
            }
            
            if viewModel.isLoadingDelete {
                LoadingView(colour: .darkColour)
            }
        }
        .interactiveDismissDisabled(viewModel.isLoadingDelete)
    }
}

#Preview {
    DeleteClubConfirmSheet(viewModel: ClubSettingsViewModel(clubModel: .example, imageCache: PreviewImageCache()))
}
