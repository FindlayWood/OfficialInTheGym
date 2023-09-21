//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import SwiftUI

struct ClubsView: View {
    
    @ObservedObject var viewModel: ClubsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("MYCLUBS")
                    .font(.title.bold())
                    .foregroundColor(Color(.darkColour))
                Spacer()
                Button {
                    viewModel.addAction()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(.darkColour))
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            if viewModel.filteredResults.isEmpty {
                if viewModel.isLoading {
                    VStack {
                        Image(systemName: "network")
                            .font(.largeTitle)
                            .foregroundColor(Color(.darkColour))
                        Text("Loading Clubs")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("Wait 1 second, we are just loading your clubs!")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
                } else if !viewModel.hasLoaded {
                    VStack {
                        ZStack {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color(.darkColour))
                            Image(systemName: "nosign")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red.opacity(0.5))
                        }
                        Text("No Clubs")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("You are not part of any clubs. You can add create your own club or join other clubs. Once you have joined a club it will appear here.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button {
                            
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(.darkColour).opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
                } else {
                    SearchBar(searchText: $viewModel.searchText, placeholder: "search clubs...")
                    VStack {
                        ZStack {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color(.darkColour))
                            Image(systemName: "nosign")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red.opacity(0.5))
                        }
                        Text("No Clubs")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("No clubs matching this search")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
                }
            } else {
                SearchBar(searchText: $viewModel.searchText, placeholder: "search clubs...")
                List {
                    ForEach(viewModel.filteredResults) { model in
                        Section {
                            Button {
                                viewModel.showClubAction(model)
                            } label: {
                                ClubRow(model: model)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.clubs)
        .background(Color(.systemBackground))
        .task {
            await viewModel.loadClubs()
        }
    }
}

struct ClubsView_Previews: PreviewProvider {
    static var previews: some View {
        ClubsView(viewModel: ClubsViewModel(clubManager: PreviewClubManager(), flow: nil))
    }
}
