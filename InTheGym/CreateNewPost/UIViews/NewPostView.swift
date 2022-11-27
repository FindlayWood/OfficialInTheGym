//
//  NewPostView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 26/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct NewPostView: View {
    // MARK: - View Model
    @StateObject var viewModel = NewPostViewModel()
    // MARK: - View Variables
    @State var showAttachmentSheet: Bool = false
    @State var showPrivacySheet: Bool = false
    // MARK: - Callback to ViewController
    var cancel: () -> ()
    
    // MARK: - View
    var body: some View {
        VStack {
            HStack {
                Button {
                    cancel()
                } label: {
                    Text("cancel")
                        .fontWeight(.bold)
                        .foregroundColor(Color(.darkColour))
                }
                Spacer()
                Button {
                    
                } label: {
                    Text("Post")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color(.darkColour))
                        .clipShape(Capsule())
                }
                .disabled(viewModel.text.isEmpty)
                .opacity(viewModel.text.isEmpty ? 0.5 : 1)
            }
            HStack(alignment: .top) {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
                ZStack(alignment: .leading) {
                    if viewModel.text.isEmpty {
                        TextEditor(text: $viewModel.placeholder)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.gray)
                            .disabled(true)
                            .cornerRadius(8)
                    }
                    TextEditor(text: $viewModel.text)
                        .font(.body.weight(.semibold))
                        .tint(Color(.darkColour))
                        .opacity(viewModel.text.isEmpty ? 0.25 : 1)
                        .cornerRadius(8)
                }
//                .frame(maxHeight: 300)
            }
            if let attachedWorkout = viewModel.attachedWorkout {
                SavedWorkoutListView(model: attachedWorkout)
            }
            if !viewModel.taggedUsers.isEmpty {
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(Color(.darkColour))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.taggedUsers, id: \.uid) { user in
                                Text("@\(user.username)")
                                    .font(.body.weight(.semibold))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 4)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
            }
            Divider()
            Spacer()
            HStack {
                Button {
                    showAttachmentSheet = true
                } label: {
                    Image(systemName: "paperclip")
                        .font(.title)
                        .foregroundColor(Color(.darkColour))
                }
                Spacer()
                Button {
                    showPrivacySheet = true
                } label: {
                    Image(systemName: viewModel.isPrivate ? "lock.fill" : "globe")
                        .font(.title)
                        .foregroundColor(Color(.darkColour))
                }
            }
        }
        .padding()
        .sheet(isPresented: $showAttachmentSheet) {
            PostAttachmentSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacySheet(isPrivate: $viewModel.isPrivate)
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(cancel: {})
    }
}