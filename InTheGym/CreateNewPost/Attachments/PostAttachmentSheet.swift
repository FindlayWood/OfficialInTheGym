//
//  PostAttachmentSheet.swift
//  InTheGym
//
//  Created by Findlay-Personal on 27/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PostAttachmentSheet: View {

    // MARK: - View Model
    @ObservedObject var viewModel: NewPostViewModel
    
    // MARK: - View Related Properties
    @State var showingWorkoutSheet: Bool = false
    @State var showingUsersSheet: Bool = false
    @State var showingClipsSheet: Bool = false
    
    // MARK: - Call backs
    var dismiss: () -> ()
    
    // MARK: - View
    var body: some View {
        NavigationView {
            List {
                Section {
                    if let attachedWorkout = viewModel.attachedWorkout {
                        SavedWorkoutListView(model: attachedWorkout)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                    } else {
                        Button {
                            showingWorkoutSheet = true
                        } label: {
                            VStack(spacing: 16) {
                                Image(systemName: "plus")
                                    .font(.title.bold())
                                Text("Attach a Workout")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(.darkColour))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.darkColour), lineWidth: 1)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                    }
                } header: {
                    HStack {
                        Text("Workouts")
                        Spacer()
                        if viewModel.attachedWorkout != nil {
                            Button {
                                viewModel.attachedWorkout = nil
                            } label: {
                                Text("Remove")
                                    .font(.caption.bold())
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                }
                Section {
                    if viewModel.taggedUsers.isEmpty {
                        Text("No tagged users.")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.taggedUsers, id: \.uid) { model in
                            UserRow(user: model)
                        }
                        .onDelete(perform: delete)
                    }
                } header: {
                    HStack {
                        Text("Tagged Users")
                        Spacer()
                        Button {
                            showingUsersSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
                Section {
                    Button {
                        showingClipsSheet = true
                    } label: {
                        Text("Add Clip")
                    }
                }
            }
            .navigationTitle("Attachments")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("dismiss")
                            .fontWeight(.bold)
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
            .sheet(isPresented: $showingWorkoutSheet) {
                SavedWorkoutSheet { viewModel.attachedWorkout = $0 }
            }
            .sheet(isPresented: $showingUsersSheet) {
                DiscoverSearchView { tagUser($0) }
            }
            .sheet(isPresented: $showingClipsSheet) {
                ClipsView { viewModel.attachedClip = $0 }
            }
        }
    }
    
    func tagUser(_ user: Users) {
        if !(viewModel.taggedUsers.contains(where: { $0.uid == user.uid })) {
            viewModel.taggedUsers.append(user)
        }
        showingUsersSheet = false
    }
    func delete(at offsets: IndexSet) {
        // delete the objects here
        viewModel.taggedUsers.remove(atOffsets: offsets)
    }
}

struct PostAttachmentSheet_Previews: PreviewProvider {
    static var previews: some View {
        PostAttachmentSheet(viewModel: NewPostViewModel(), dismiss: {})
    }
}
