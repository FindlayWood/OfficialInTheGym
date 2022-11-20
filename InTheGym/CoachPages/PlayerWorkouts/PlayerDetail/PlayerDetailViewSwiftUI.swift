//
//  PlayerDetailViewSwiftUI.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PlayerDetailViewSwiftUI: View {
    @ObservedObject var viewModel: PlayerDetailViewModel
    var body: some View {
        List {
            Section {
                VStack {
                    if let image = viewModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.secondary)
                    }
                    Text("\(viewModel.user.firstName) \(viewModel.user.lastName)")
                        .font(.custom("Menlo-Bold", size: 25, relativeTo: .title))
                        .foregroundColor(.primary)
                    Text("@\(viewModel.user.username)")
                        .font(.title2.weight(.medium))
                        .foregroundColor(Color(.darkColour))
                    UserFollowingSwiftUI(user: viewModel.user)
                    .padding()
                    if let profileBio = viewModel.user.profileBio {
                        Text(profileBio)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.action.send(.profile)
                }
            } header: {
                Text("Public Profile")
            }
            // TODO: - fade out if user not subscribed
            Section {
                HStack {
                    Image("monitor_icon")
                        .resizable()
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("Performance Center")
                            .font(.headline)
                        Text("Check out the performance center for this player.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.action.send(.performance)
                }
            } header: {
                Text("Performance Center")
            }
            // TODO: - Show 3 most recent workouts
            Section {
//                Button {
//                    viewModel.action.send(.workouts)
//                } label: {
//                    Text("View Workouts")
//                }
//                Button {
//                    viewModel.action.send(.addWorkout)
//                } label: {
//                    Text("Add New Workout")
//                }
                if viewModel.lastWorkouts.isEmpty {
                    Text("This player has no workouts.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.lastWorkouts, id: \.id) { model in
                        Button {
                            viewModel.action.send(.workout(model))
                        } label: {
                            WorkoutListView(model: model)
                        }
                        .padding(.bottom)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 0, trailing: 1))
                        
                    }
                }
                
            } header: {
                HStack {
                    Text("Recent Workouts")
                    Spacer()
                    if !viewModel.lastWorkouts.isEmpty {
                        Button {
                            viewModel.action.send(.workouts)
                        } label: {
                            Text("see all")
                                .font(.footnote.bold())
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
                
                
            }
        }
        .onAppear {
            viewModel.getImage()
            viewModel.getFollowerCount()
            viewModel.getFollowingCount()
        }
        .task {
            await viewModel.getLastWorkouts()
        }
    }
}

struct PlayerDetailViewSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        PlayerDetailViewSwiftUI(viewModel: PlayerDetailViewModel())
    }
}
