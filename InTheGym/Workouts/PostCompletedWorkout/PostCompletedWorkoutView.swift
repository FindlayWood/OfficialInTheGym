//
//  PostCompletedWorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PostCompletedWorkoutView: View {
    
    var viewModel: PostCompletedWorkoutViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(.darkColour))
            Text("Workout Completed!")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding()
            VStack (alignment: .leading) {
                Text("Post to Timeline")
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                    .font(.subheadline)
                Button {
                    viewModel.postWorkoutSelected.send(())
                } label: {
                    HStack {
                        Image("benchpress_icon")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack (alignment: .leading) {
                            Text("Post Workout")
                                .foregroundColor(.primary)
                                .fontWeight(.bold)
                            Text(viewModel.isPrivate ? "This workout is private cant post to timeline" : "Post this workout to the timeline")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isPrivate ? Color(.secondarySystemBackground) : Color.white)
                .cornerRadius(16)
                if viewModel.canPostClips {
                    Button {
                        
                    } label: {
                        HStack {
                            Image("clip_icon")
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack (alignment: .leading) {
                                Text("Post Clips")
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                                Text("Post Clips from this workout to the timeline.")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
                if viewModel.canPostSummary {
                    Button {
                        
                    } label: {
                        HStack {
                            Image("clipboard_icon")
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack (alignment: .leading) {
                                Text("Post Summary")
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                                Text("Post the summary from this workout to the timeline")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
                Spacer()
                Button {
                    viewModel.dismissSelected.send(())
                } label: {
                    Text("Dismiss")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isPrivate ? Color(.secondarySystemBackground) : Color.white)
                .cornerRadius(16)
            }
            .padding()

        Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.all)
    }
}

struct PostCompletedWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        PostCompletedWorkoutView(viewModel: PostCompletedWorkoutViewModel())
    }
}
