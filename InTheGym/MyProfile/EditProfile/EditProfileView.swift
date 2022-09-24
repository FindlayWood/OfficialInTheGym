//
//  EditProfileView.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct EditProfileViewSwiftUI: View {
    
    @ObservedObject var viewModel: EditProfileViewModel
    
    @State private var showingImagePicker = false
   
    
    var body: some View {
        NavigationView {
            VStack {
                if let profileImage = viewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    Button {
                        showingImagePicker = true
                    } label: {
                        Text("Edit Photo")
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .padding()
                        .frame(width: 100, height: 100)
                    Button {
                        showingImagePicker = true
                    } label: {
                        Text("Add Photo")
                            .foregroundColor(Color(.darkColour))
                    }
                }
                TextEditor(text: $viewModel.bioText)
                    .font(.body.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.vertical)
                    .frame(height: 200)
                HStack {
                    Spacer()
                    Text(viewModel.characterRemaining, format: .number)
                        .font(.caption2)
                        .foregroundColor(Color(.tertiaryLabel))
                }
                Spacer()
            }
            .padding(.horizontal)
            .onAppear {
                viewModel.initialLoad()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $viewModel.newProfileImage)
            }
            .onChange(of: viewModel.newProfileImage) { newValue in
                viewModel.profileImage = newValue
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.saving {
                        Button {
                            viewModel.dismiss.send(true)
                        } label: {
                            Text("Dismiss")
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.saving {
                        ProgressView()
                    } else {
                        Button {
                            viewModel.saving = true
                            viewModel.saveImage()
                            viewModel.saveBio()
                        } label: {
                            Text("Save")
                                .bold()
                                .foregroundColor(viewModel.canSave ? Color(.darkColour) : Color(.lightGray))
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
