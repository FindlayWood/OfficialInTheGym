//
//  PublicFollowersFollowingView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 19/02/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct PublicFollowersFollowingView: View {
    
    @ObservedObject var viewModel: PublicFollowersViewModel
    @Namespace var namespace
    var selectedUser: (Users) -> ()
    
    var body: some View {
        VStack {
            HStack {
                ForEach(FollowerFollowingOptions.allCases, id: \.self) { option in
                    Button {
                        withAnimation {
                            viewModel.switchSegment(to: option)
                        }
                    } label: {
                        VStack {
                            Text(option.title)
                                .font(.headline)
                                .foregroundColor(option == viewModel.optionSelected ? Color(.darkColour) : .secondary)
                            if option == viewModel.optionSelected {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(.darkColour))
                                    .frame(height: 4)
                                    .matchedGeometryEffect(id: "bubble", in: namespace)
                            } else {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.clear)
                                    .frame(height: 4)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            List {
                if viewModel.usersToShow.isEmpty {
                    if viewModel.optionSelected == .following {
                        Text("\(viewModel.user.username) is not following anyone.")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(viewModel.user.username) has no followers.")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(viewModel.usersToShow, id: \.id) { model in
                        UserRow(user: model)
                            .onTapGesture {
                                selectedUser(model)
                            }
                    }
                }
            }
        }
    }
}
