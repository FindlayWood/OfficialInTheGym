//
//  TaggedUsersView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 11/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct TaggedUsersView: View {
    
    @ObservedObject var viewModel: TaggedUsersViewModel
    
    var action: (Users) -> ()
    
    var body: some View {
        List {
            ForEach(viewModel.taggedUsers, id: \.uid) { model in
                Button {
                    action(model)
                } label: {
                    UserRow(user: model)
                }
            }
        }
    }
}

struct TaggedUsersView_Previews: PreviewProvider {
    static var previews: some View {
        TaggedUsersView(viewModel: TaggedUsersViewModel(), action: { _ in })
    }
}
