//
//  EditPlayerSubview.swift
//
//
//  Created by Findlay Wood on 17/02/2024.
//

import PhotosUI
import SwiftUI

struct EditPlayerSubview: View {
    
    @ObservedObject var viewModel: PlayerDetailViewModel
    
    @State private var profileImage: UIImage?
    
    @State private var newName: String = ""
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadingImageData: Bool = false
    
    var body: some View {
        ZStack {
            List {
                 Section {
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
                         PhotosPicker(selection: $selectedPhotos,
                                      maxSelectionCount: 1,
                                      matching: .images,
                                      label: {
                             Text("Select Photo")
                         })
                         .onChange(of: selectedPhotos) { _ in
                             convertDataToImage()
                         }
                     }
                     .frame(maxWidth: .infinity)
                 } header: {
                     Text("Edit Profile Image")
                 }
                 .listRowBackground(Color.clear)
                 
                
                Section {
                    TextField("change display name", text: $viewModel.newName)
                        .padding()
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text("Edit Display Name")
                }
                 
                
                Section {
                    
                    ForEach(Sport.rugby.positions, id: \.self) { position in
                        SelectPositionRow(selected: viewModel.isPositionSelected(position), position: position) {
                            viewModel.toggleSelectedPosition(position)
                        }
                        .padding(.bottom)
                        .padding(.horizontal, 4)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                } header: {
                    Text("Edit Positions")
                }
                
                Section {
                    Spacer()
                        .frame(height: 100)
                }
                .listRowBackground(Color.clear)
         }
            VStack {
                Spacer()
                MainButton(text: "Save", disabled: true) {
                    
                }
                .padding()
                
                Button {
                    
                } label: {
                    Text("cancel")
                        .foregroundStyle(Color.red)
                }
            }
        }
        .onAppear {
            viewModel.imageCache.getImage(for: ImageConstants.playerPath(viewModel.playerModel.id, in: viewModel.playerModel.clubID)) { image in
                profileImage = image
            }
        }
    }
    
    func convertDataToImage() {
        // reset the images array before adding more/new photos
        profileImage = nil
        loadingImageData = true
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            profileImage = image
                        }
                    }
                }
            }
        }
        
        // uncheck the images in the system photo picker
        selectedPhotos.removeAll()
    }
}

#Preview {
    EditPlayerSubview(viewModel: .init(playerModel: .example, groupLoader: PreviewGroupLoader(), teamLoader: PreviewTeamLoader(), imageCache: PreviewImageCache()))
}
