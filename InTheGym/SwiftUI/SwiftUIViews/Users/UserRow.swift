//
//  UserRow.swift
//  InTheGym
//
//  Created by Findlay-Personal on 25/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct UserRow: View {
    @StateObject var viewModel = ViewModel()
    var user: Users
    var body: some View {
        HStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(user.displayName)
                        .font(.custom("Menlo-Bold", size: 22, relativeTo: .title))
                        .foregroundColor(Color(.darkColour))
                    if user.eliteAccount {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(.goldColour))
                    } else if user.verifiedAccount {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(.lightColour))
                    }
                }
                Text("@\(user.username)")
                    .font(.body.weight(.medium))
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            viewModel.getImage(for: user)
        }
    }
}

extension UserRow {
    final class ViewModel: ObservableObject {
        // MARK: - Published Properties
        @Published var image: UIImage?
        
        // MARK: - Methods
        func getImage(for user: Users) {
            let downloadModel = ProfileImageDownloadModel(id: user.uid)
            ImageCache.shared.load(from: downloadModel) { [weak self] result in
                guard let image = try? result.get() else {return}
                self?.image = image
            }
        }
    }
}
