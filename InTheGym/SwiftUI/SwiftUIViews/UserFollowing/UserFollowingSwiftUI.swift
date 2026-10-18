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
            Spacer()
            VStack {
                Text(viewModel.followerCount, format: .number)
                    .font(.subheadline.weight(.semibold))
                Text("Followers")
                    .font(.subheadline.weight(.medium))
            }
            Spacer()
            VStack {
                Text(viewModel.followingCount, format: .number)
                    .font(.subheadline.weight(.semibold))
                Text("Following")
                    .font(.subheadline.weight(.medium))
            }
            Spacer()
            VStack {
                Image(uiImage: user.accountType == .coach ? UIImage.legacyIcon("person.badge.shield.checkmark.fill") : UIImage.legacyIcon("figure.run"))
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(user.accountType == .coach ? "Coach" : "Player")
                    .font(.subheadline.weight(.medium))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
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
