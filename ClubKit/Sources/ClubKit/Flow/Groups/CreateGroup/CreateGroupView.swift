//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import SwiftUI

struct CreateGroupView: View {
    
    @ObservedObject var viewModel: CreateGroupViewModel
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Create New Workout Group")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                            Text("Creating a new Workout Group will add it to the club. Groups are great for assigning workoust to specific players.")
                                .font(.footnote.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Group Name")
                            TextField("enter group name...", text: $viewModel.groupName)
                                .tint(Color(.darkColour))
                                .autocorrectionDisabled()
                        }
                    } header: {
                        Text("Name")
                    }
                    
                    Section {
                        Button {
                            viewModel.selectedPlayers?()
                        } label: {
                            Text("Add Players")
                        }
                        ForEach(viewModel.selectedPlayersList) { model in
                            PlayerRow(model: model)
                        }
                        .onDelete(perform: delete)
                    } header: {
                        Text("Players")
                    }
                    
                }
                Button {
                    viewModel.create()
                } label: {
                    Text("Create Group")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(.darkColour).opacity(viewModel.buttonDisabled ? 0.3 : 1))
                        .clipShape(Capsule())
                        .shadow(radius: viewModel.buttonDisabled ? 0 : 4)
                }
                .disabled(viewModel.buttonDisabled)
                .padding()
            }

            if viewModel.isUploading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    ProgressView()
                }
            }
            if viewModel.uploaded {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.green)
                        Text("Created New Group")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(4)
                }
            }
            if viewModel.errorUploading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.red)
                        Text("Error, please try again!")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(4)
                }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.selectedPlayersList.remove(atOffsets: offsets)
    }
}

struct CreateGroupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGroupView(viewModel: .init(clubModel: .example, creationService: PreviewGroupService()))
    }
}
