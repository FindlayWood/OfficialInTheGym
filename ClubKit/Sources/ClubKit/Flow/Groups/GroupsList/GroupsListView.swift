//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 19/11/2023.
//

import SwiftUI

struct GroupsListView: View {
    
    @ObservedObject var viewModel: GroupsListViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                VStack {
                    Image(systemName: "network")
                        .font(.largeTitle)
                        .foregroundColor(Color(.darkColour))
                    Text("Loading Groups")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Text("Wait 1 second, we are just loading your groups!")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
            } else {
                if viewModel.groups.isEmpty {
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
                        Text("No Groups")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("This club currently has no Workout Groups. You can create a Workout Group for this club. Once you have created a Workout Group it will appear here.")
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
                    SearchBar(searchText: $viewModel.searchText, placeholder: "search groups...")
                        .background(Capsule()
                            .foregroundColor(Color(.systemBackground)))
                    
                    if viewModel.searchedGroups.isEmpty {
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
                            Text("No Groups")
                                .font(.title.bold())
                                .foregroundColor(Color(.darkColour))
                            if viewModel.searchText.isEmpty {
                                Text("This club currently has no Workout Groups. You can create a Workout Group for this club. Once you have created a Workout Group it will appear here.")
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
                            } else {
                                Text("No Workout Groups. Change your search term.")
                                    .font(.footnote.bold())
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.secondarySystemBackground))
                    } else {
                        List {
                            ForEach(viewModel.groups) { model in
                                Button {
                                    viewModel.selectedGroupAction(model)
                                } label: {
                                    GroupRow(model: model)
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                            .padding(.bottom)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.load()
        }
    }
}

struct GroupsListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsListView(viewModel: .init(groupLoader: PreviewGroupLoader(), clubModel: .example))
    }
}
