//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 03/12/2023.
//

import CoreImage
import PhotosUI
import SwiftUI

struct LinkPlayerView: View {
    
    @ObservedObject var viewModel: LinkPlayerViewModel
    
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
                case let .gotUserProfile(model):
                    List {
                        
                        Section {
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Scan Complete")
                                        .font(.headline)
                                    Image(systemName: "checkmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.green)
                                        .frame(width: 50)
                                        .padding(.bottom)
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.cornerRadius(10).shadow(radius: 2, y: 2))
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 2, leading: 2, bottom: 2, trailing: 2))
                        
                        Section {
                            VStack {
                                VStack(alignment: .leading) {
                                    Text("User Account")
                                        .font(.headline)
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Text(model.displayName)
                                                .font(.headline)
                                            Text("@")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(Color.secondary)
                                            + Text(model.username)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(.primary)
                                        }
                                        Spacer()
                                    }
                                    
                                    Button {
                                        Task {
                                            await viewModel.link(to: model)
                                        }
                                    } label: {
                                        Text("Link to this user")
                                            .padding()
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .background(Color(.darkColour))
                                            .clipShape(Capsule())
                                            .shadow(radius: 4)
                                    }
                                    .padding(.vertical)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.cornerRadius(10).shadow(radius: 2, y: 2))
                                
                                
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 2, leading: 2, bottom: 2, trailing: 2))
                        
                    }
                case .linking:
                    VStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Linking Player!")
                                .font(.largeTitle.bold())
                                .foregroundStyle(Color(.darkColour))
                            Text("We are just linking this account to the player account in your club. It should not take long.")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color(.darkColour))
                            ProgressView()
                                .tint(Color(.darkColour))
                                .padding()
                        }
                        .padding()
                        Spacer()
                    }
                case .success:
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
                case .error:
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
                            Text("A player in this club is already linked to this InTheGym account. You can only link a player to one account.")
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
    let vm = LinkPlayerViewModel(scannerService: PreviewScannerService(),
                                 clubModel: .example,
                                 loader: PreviewPlayerLoader(),
                                 playerModel: .example,
                                 linkService: PreviewLinkPlayerService())
    vm.viewState = .scanError
    
    return LinkPlayerView(viewModel: vm)
}
