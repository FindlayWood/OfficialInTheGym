//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 26/11/2023.
//

import CoreImage
import PhotosUI
import SwiftUI

struct QRScannerView: View {
    
    @ObservedObject var viewModel: QRScannerViewModel
    
    @State private var libraryImage: UIImage?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadingImageData: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .scanning:
                    ZStack {
                        
                        if let libraryImage {
                            Image(uiImage: libraryImage)
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .scaledToFit()
                            if loadingImageData {
                                ProgressView()
                            }
                        } else if loadingImageData {
                            ProgressView()
                        } else {
                            CodeScannerView(codeTypes: [.qr], simulatedData: QRConstants.simulatedData, completion: viewModel.handleScan)
                        }
                        
                        
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 305, height: 305)
                                .foregroundStyle(Color(.darkColour))
                            
                            RoundedRectangle(cornerRadius: 17.5)
                                .frame(width: 300, height: 300)
                                .blendMode(.destinationOut)
                            
                        }
                        .compositingGroup()
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                PhotosPicker(selection: $selectedPhotos,
                                             maxSelectionCount: 1,
                                             matching: .images,
                                             label: {
                                    Image(systemName: "photo.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(Color(.lightColour))
                                })
                            }
                            .padding()
                        }
                    }
                    .onChange(of: selectedPhotos) { _ in
                        convertDataToImage()
                    }
                    .onChange(of: libraryImage) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            loadLibraryImage()
                        }
                    }
                    
                case .scanError:
                    VStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Oops!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color(.darkColour))
                            Text("It seems like there was an error. Please try scanning the image again. Make sure that the QR code is one from inside the InTheGym app.")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color(.darkColour))
                        }
                        .padding()
                        Spacer()
                        VStack {
                            Button {
                                viewModel.viewState = .scanning
                            } label: {
                                Text("Try Again")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.white)
                                    .padding(.top)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Color(.lightColour)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .ignoresSafeArea()
                        )
                    }
                case .loadingScan:
                    VStack {
                        Spacer()
                        VStack {
                            Text("Got it!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color(.darkColour))
                            ProgressView()
                                .tint(Color(.darkColour))
                                .padding()
                            Text("Just loading the image")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color(.darkColour))
                        }
                        .padding()
                        Spacer()
                        VStack {
                            Button {
                                viewModel.viewState = .scanning
                            } label: {
                                Text("cancel")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.white)
                                    .padding(.top)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Color(.lightColour)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .ignoresSafeArea()
                        )
                    }
                case let .gotUserProfile(userModel):
                    List {
                        
                        Section {
                            VStack(alignment: .leading) {
                                Text("Display Name")
                                TextField("enter display name...", text: $viewModel.displayName)
                                    .tint(Color(.darkColour))
                                    .autocorrectionDisabled()
                            }
                        } header: {
                            Text("Name")
                        }
                        
                        Section {
                            ForEach(viewModel.teams, id: \.id) { model in
                                HStack {
                                    Text(model.teamName)
                                        .font(.headline)
                                    Spacer()
                                    Button {
                                        viewModel.toggleSelectedTeam(model)
                                    } label: {
                                        Image(systemName: (viewModel.selectedTeams.contains(where: { $0.id == model.id })) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(Color(.darkColour))
                                    }
                                }
                            }
                        } header: {
                            Text("Teams")
                        }
                        
                        Section {
                            ForEach(viewModel.playerPositions, id: \.self) { position in
                                Text(position.title)
                            }
                            Menu {
                                ForEach(viewModel.selectedSport.positions, id: \.self) { position in
                                    Button(position.title) { viewModel.playerPositions.append(position)}
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color(.darkColour))
                            }
                        } header: {
                            Text("All Positions")
                        }
                        
                        Section {
                            Button {
                                Task {
                                    await viewModel.addPlayer(userModel)
                                }
                            } label: {
                                Text("Create Player")
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
                    .onAppear {
                        viewModel.loadTeams()
                    }
                case .loadingAdd:
                    VStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Adding Player!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color(.darkColour))
                            Text("We are just adding your new player to the club. It should not take long.")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color(.darkColour))
                            ProgressView()
                                .tint(Color(.darkColour))
                                .padding()
                        }
                        .padding()
                        Spacer()
                    }
                case .addSuccess:
                    VStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Player Added!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color(.darkColour))
                            Text("Great! Your new player has been added to the club!")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color(.darkColour))
                        }
                        .padding()
                        Spacer()
                    }
                case .addFail:
                    VStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Oops!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color(.darkColour))
                            Text("It seems like there was an error. Please try scanning the image again. Make sure that the QR code is one from inside the InTheGym app.")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color(.darkColour))
                        }
                        .padding()
                        Spacer()
                        VStack {
                            Button {
                                viewModel.viewState = .scanning
                            } label: {
                                Text("Try Again")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.white)
                                    .padding(.top)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Color(.lightColour)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .ignoresSafeArea()
                        )
                    }
                case .alreadyJoined:
                    VStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Already Joined!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color(.darkColour))
                            Text("This user is already part of this club.")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color(.darkColour))
                        }
                        .padding()
                        Spacer()
                        VStack {
                            Button {
                                viewModel.viewState = .scanning
                            } label: {
                                Text("ok")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.white)
                                    .padding(.top)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Color(.lightColour)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .ignoresSafeArea()
                        )
                    }
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func convertDataToImage() {
        // reset the images array before adding more/new photos
        libraryImage = nil
        loadingImageData = true
        
        if !selectedPhotos.isEmpty {
            for eachItem in selectedPhotos {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            libraryImage = image
                        }
                    }
                }
            }
        }
        
        // uncheck the images in the system photo picker
        selectedPhotos.removeAll()
    }
    
    func loadLibraryImage() {
        loadingImageData = false
        viewModel.viewState = .loadingScan
        guard let libraryImage else {
            viewModel.viewState = .scanError
            self.libraryImage = nil
            return }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        
        guard let ciImage = CIImage(image: libraryImage) else {
            viewModel.viewState = .scanError
            self.libraryImage = nil
            return }
        
        var qrCodeLink = ""
        
        let features = detector.features(in: ciImage)
        
        if features.isEmpty {
            viewModel.viewState = .scanError
            self.libraryImage = nil
        } else {
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
                if qrCodeLink == "" {
                    viewModel.viewState = .scanError
                } else {
                    let corners = [
                        feature.bottomLeft,
                        feature.bottomRight,
                        feature.topRight,
                        feature.topLeft
                    ]
                    let result = ScanResult(string: qrCodeLink, type: .qr, image: libraryImage, corners: corners)
                    viewModel.handleScan(result: .success(result))
                }
            }
        }
    }
}

#Preview {
    let vm = QRScannerViewModel(scannerService: PreviewScannerService(), clubModel: .example, loader: PreviewPlayerLoader(), teamLoader: PreviewTeamLoader(), creationService: PreviewPlayerCreationService())
    
    vm.viewState = .scanning
    
    return QRScannerView(viewModel: vm)
}
