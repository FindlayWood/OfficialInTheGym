//
//  UserFollowingSwiftUI.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct UserFollowingSwiftUI: View {
    @StateObject var viewModel = ViewModel()
    var user: Users
    var body: some View {
        HStack(alignment: .bottom) {
            VStack {
                Text(viewModel.followerCount, format: .number)
                    .font(.subheadline.weight(.semibold))
                Text("Followers")
                    .font(.body.weight(.medium))
            }
            VStack {
                Text(viewModel.followingCount, format: .number)
                    .font(.subheadline.weight(.semibold))
                Text("Following")
                    .font(.body.weight(.medium))
            }
            VStack {
                Image(user.admin ? "coach_icon" : "player_icon")
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(user.admin ? "Coach" : "Player")
                    .font(.body.weight(.medium))
            }
        }
        .onAppear {
            viewModel.getFollowerCount(user)
            viewModel.getFollowingCount(user)
        }
    }
}

struct UserFollowingSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        UserFollowingSwiftUI(viewModel: UserFollowingSwiftUI.ViewModel(), user: Users.nilUser)
    }
}
