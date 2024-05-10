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
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                            TextField("enter club display name...", text: $viewModel.displayName)
                        }
                        .padding()
                        .background(
                            LinearGradient(colors: [Color(.offWhiteColour), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 4)
                        )
                        .padding(.bottom)
                        .padding(.horizontal, 4)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    
                
                    Section {
                        VStack(alignment: .leading) {
                            Text("Tag Line")
                                .font(.headline)
                                .foregroundStyle(Color.primary)
                            TextField("enter club tag line...", text: $viewModel.tagline)
                        }
                        .padding()
                        .background(
                            LinearGradient(colors: [Color(.offWhiteColour), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 4)
                        )
                        .padding(.bottom)
                        .padding(.horizontal, 4)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    
                    Section {
                        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                            ForEach(Sport.allCases, id: \.self) { sport in
                                SelectSportRow(sport: sport, selected: viewModel.sport == sport) {
                                    withAnimation {
                                        viewModel.sport = sport
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Club Sport")
                    } footer: {
                        Text("\(viewModel.sport.title) selected")
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                            ForEach(ClubRole.allCases, id: \.self) { role in
                                SelectRoleRow(role: role, selected: viewModel.userRole == role) {
                                    withAnimation {
                                        viewModel.userRole = role
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Your Role")
                    } footer: {
                        Text("\(viewModel.userRole.rawValue.capitalized) selected")
                    }
                    .listRowBackground(Color.clear)
                    
                    if viewModel.userRole == .player {
                        Section {
                            ForEach(viewModel.sport.positions, id: \.self) { position in
                                SelectPositionRow(selected: viewModel.isPositionSelected(position), position: position) {
                                    viewModel.toggleSelectedPosition(position)
                                }
                                .padding(.bottom)
                                .padding(.horizontal, 4)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        } header: {
                            Text("Select Positions")
                        }
                    }
                    
                    Section {
                        Spacer()
                            .frame(height: 100)
                            .listRowBackground(Color.clear)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                
                VStack {
                    Spacer()
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
                    .padding()
                }

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
        ClubCreationView(viewModel: ClubCreationViewModel(service: PreviewClubCreationService(), clubManager: PreviewClubManager()))
    }
}
