//
//  CommentAttachmentSheet.swift
//  InTheGym
//
//  Created by Findlay-Personal on 25/02/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct CommentAttachmentSheet: View {
    
    // MARK: - View Model
    @ObservedObject var viewModel: CommentSectionViewModel
    
    // MARK: - View Related Properties
    @State var showingWorkoutSheet: Bool = false
    @State var showingUsersSheet: Bool = false
    @State var showingClipsSheet: Bool = false
    
    // MARK: - Call backs
    var addWorkout: () -> ()
    var addUser: () -> ()
    var dismiss: () -> ()
    
    // MARK: - View
    var body: some View {
            List {
                Section {
                    if let attachedWorkout = viewModel.attachedSavedWorkout {
                        SavedWorkoutListView(model: attachedWorkout)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                    } else {
                        Button {
                            addWorkout()
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
                        if viewModel.attachedSavedWorkout != nil {
                            Button {
                                viewModel.removeAttachedSavedWorkout()
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
                            addUser()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
            }
    }
    func delete(at offsets: IndexSet) {
        // delete the objects here
        viewModel.removeTaggedUsers(at: offsets)
    }
}

struct CommentAttachmentSheet_Previews: PreviewProvider {
    static var previews: some View {
        CommentAttachmentSheet(viewModel: CommentSectionViewModel(), addWorkout: {}, addUser: {}, dismiss: {})
    }
}
