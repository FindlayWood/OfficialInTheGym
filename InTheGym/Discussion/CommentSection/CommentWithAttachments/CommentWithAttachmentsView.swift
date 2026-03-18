//
//  CommentWithAttachmentsView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 22/02/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct CommentWithAttachmentsView: View {
    // MARK: - View Model
    @ObservedObject var viewModel: CommentSectionViewModel
    // MARK: - View Variables
    @State var showAttachmentSheet: Bool = false
    @State var showPrivacySheet: Bool = false
    @State var profileImage: UIImage?
    // MARK: - Callback to ViewController
    var post: () -> ()
    var addAttachments: () -> ()
    var changePrivacy: () -> ()
    var cancel: () -> ()
    
    // MARK: - View
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                if let profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                }
                VStack(alignment: .leading) {
                    Text("replying to \(viewModel.mainPost.username)'s post")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(Color(.lightColour))
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
                }
            }
            if let attachedSavedWorkout = viewModel.attachedSavedWorkout {
                SavedWorkoutListView(model: attachedSavedWorkout)
            }
            if let attachedWorkout = viewModel.attachedWorkout {
                WorkoutListView(model: attachedWorkout)
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
                    addAttachments()
                } label: {
                    Image(systemName: "paperclip")
                        .font(.title)
                        .foregroundColor(Color(.darkColour))
                }
                Spacer()
                Button {
                    changePrivacy()
                } label: {
                    Image(systemName: viewModel.isPrivate ? "lock.fill" : "globe")
                        .font(.title)
                        .foregroundColor(Color(.darkColour))
                }
            }
        }
        .padding()
        .onAppear {
            loadProfileImage()
            addAttachments()
        }
    }
    
    func loadProfileImage() {
        ImageAPIService.shared.getProfileImage(for: UserDefaults.currentUser.uid) { image in
            self.profileImage = image
        }
    }
}

struct CommentWithAttachmentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentWithAttachmentsView(viewModel: CommentSectionViewModel(), post: {}, addAttachments: {}, changePrivacy: {}, cancel: {})
    }
}
