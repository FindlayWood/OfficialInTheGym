//
//  ClubCreationView.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import PhotosUI
import SwiftUI

struct ClubCreationView: View {
    
    @ObservedObject var viewModel: ClubCreationViewModel
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadingImageData: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        ZStack {
                            VStack {
                                if let libraryImage = viewModel.libraryImage {
                                    Image(uiImage: libraryImage)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundStyle(Color.gray)
                                        .frame(width: 100, height: 100)
                                }
                                PhotosPicker(selection: $selectedPhotos,
                                             maxSelectionCount: 1,
                                             matching: .images,
                                             label: {
                                    Text("Select Photo")
                                })
                            }
                            .onChange(of: selectedPhotos) { _ in
                                convertDataToImage()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        VStack(alignment: .leading) {
                            Text("Display Name")
                            TextField("enter display name...", text: $viewModel.displayName)
                        }
                    } header: {
                        Text("Name")
                    }
                
                    Section {
                        VStack(alignment: .leading) {
                            Text("Tag Line")
                            TextField("enter tag line...", text: $viewModel.tagline)
                        }
                    } header: {
                        Text("Tag")
                    }
                    
                    Section {
                        Picker("What is the club sport?", selection: $viewModel.sport) {
                            ForEach(Sport.allCases, id: \.self) { sport in
                                Text(sport.title)
                                    .tag(sport)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.sport) { newValue in
                            viewModel.updateSport(to: newValue)
                        }
                    }
                    
                    Section {
                        Picker("What is your role?", selection: $viewModel.userRole) {
                            ForEach(ClubRole.allCases, id: \.self) { role in
                                Text(role.rawValue)
                                    .tag(role)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Your Role")
                    }
                    
                    if viewModel.userRole == .player {
                        Section {
                            ForEach(viewModel.selectedPositions, id: \.self) { position in
                                Text(position.title)
                            }
                            Menu {
                                ForEach(viewModel.sport.positions, id: \.self) { position in
                                    Button(position.title) { viewModel.addSelectedPosition(position) }
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(.darkColour))
                            }
                        } header: {
                            Text("All Positions")
                        }
                    }
                    
                    Section {
                        Button {
                            viewModel.createAction()
                        } label: {
                            Text("Create Club")
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(Color(.darkColour).opacity(viewModel.buttonDisabled ? 0.3 : 1))
                                .clipShape(Capsule())
                                .shadow(radius: viewModel.buttonDisabled ? 0 : 4)
                        }
                        .disabled(viewModel.buttonDisabled)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 2, leading: 2, bottom: 2, trailing: 2))
                }
                .edgesIgnoringSafeArea(.bottom)

                if viewModel.isUploading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        ProgressView()
                    }
                }
                if viewModel.uploaded {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.green)
                            Text("Created New Club")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(4)
                    }
                }
                if viewModel.errorUploading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.red)
                            Text("Error, please try again!")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(4)
                    }
                }
            }
            .navigationTitle("Create Club")
            .navigationBarTitleDisplayMode(.inline)
        }

    }
    
    func convertDataToImage() {
        // reset the images array before adding more/new photos
        viewModel.libraryImage = nil
        loadingImageData = true
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            viewModel.libraryImage = image
                        }
                    }
                }
            }
        }
        
        // uncheck the images in the system photo picker
        selectedPhotos.removeAll()
    }
}

struct ClubCreationView_Previews: PreviewProvider {
    private struct PreviewService: ClubCreationService {
        func createNewClub(with data: NewClubData) async -> Result<NewClubData, RemoteCreationService.Error> {
            return .failure(.failed)
        }
    }
    static var previews: some View {
        ClubCreationView(viewModel: ClubCreationViewModel(service: PreviewService(), clubManager: PreviewClubManager()))
    }
}
