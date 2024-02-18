//
//  PlayerDetailView.swift
//
//
//  Created by Findlay Wood on 10/12/2023.
//

import SwiftUI

struct PlayerDetailView: View {
    
    @ObservedObject var viewModel: PlayerDetailViewModel
    
    @State private var profileImage: UIImage?
    
    var body: some View {
        if viewModel.isEditing {
            EditPlayerSubview(viewModel: viewModel)
        } else {
            ScrollView {
                VStack {
                    
                    if let profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundColor(.secondary)
                                .frame(width: 100, height: 100)
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 50)
                                .padding(.bottom)
                        }
                    }
                    
                    Text(viewModel.playerModel.displayName)
                        .font(.headline)
                    
                    Text(viewModel.playerModel.positions.map { $0.title }.joined(separator: ", "))
                        .font(.subheadline)
                    
                    Text(viewModel.playerModel.createdDate, format: .dateTime.month().year())
                        .font(.footnote)
                    
                    VStack(alignment: .leading) {
                        Text("Linked Account")
                            .font(.headline)
                        if viewModel.playerModel.linkedAccountUID != nil {
                            Text("This player is linked to an InTheGym Account.")
                        } else {
                            Text("This player is not linked to an InTheGym account. If this player has an InTheGym account you can link their account to this player account. Then they will have access to certain aspects of this club.")
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                            MainButton(text: "Link Player", disabled: false, overlayImage: "qrcode.viewfinder") {
                                viewModel.linkAction()
                            }
                            .padding()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.cornerRadius(10).shadow(radius: 2, y: 2))
                    
                }
                .padding()
                
            }
            .onAppear {
                viewModel.imageCache.getImage(for: ImageConstants.playerPath(viewModel.playerModel.id, in: viewModel.playerModel.clubID)) { image in
                    profileImage = image
                }
            }
        }
    }
}

#Preview {
    PlayerDetailView(viewModel: .init(playerModel: .example, clubModel: .example, groupLoader: PreviewGroupLoader(), teamLoader: PreviewTeamLoader(), imageCache: PreviewImageCache(), updateService: PreviewUpdatePlayerDetailService()))
}
