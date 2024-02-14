//
//  ClubSettingsView.swift
//
//
//  Created by Findlay Wood on 07/02/2024.
//

import SwiftUI

struct ClubSettingsView: View {
    
    @ObservedObject var viewModel: ClubSettingsViewModel
    @State private var profileImage: UIImage?
    @State private var isShowingDeleteSheet: Bool = false
    
    var body: some View {
        List {
            
            Section {
                HStack {
                    Spacer()
                    VStack {
                        if let profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            Section {
                VStack {
                    Text(viewModel.clubModel.clubName)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    Text(viewModel.clubModel.tagline)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            Section {
                Text(viewModel.clubModel.createdDate, format: .dateTime.day().month().year())
                    .fontWeight(.medium)
            } header: {
                Text("Created")
            }
            
            Section {
                Button {
                    
                } label: {
                    Text("Leave club")
                        .foregroundStyle(Color.red)
                }
                Button {
                    isShowingDeleteSheet.toggle()
                } label: {
                    Text("Delete club")
                        .foregroundStyle(Color.red)
                }
            }
            
        }
        .sheet(isPresented: $isShowingDeleteSheet, content: {
            DeleteClubConfirmSheet(viewModel: viewModel)
        })
        .onAppear {
            viewModel.imageCache.getImage(for: ImageConstants.clubPath(viewModel.clubModel.id)) { image in
                self.profileImage = image
            }
        }
    }
}

#Preview {
    ClubSettingsView(viewModel: .init(clubModel: .example, imageCache: PreviewImageCache()))
}
