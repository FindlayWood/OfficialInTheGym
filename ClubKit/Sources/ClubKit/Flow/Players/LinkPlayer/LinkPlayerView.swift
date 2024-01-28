//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 03/12/2023.
//

import SwiftUI

struct LinkPlayerView: View {
    
    @ObservedObject var viewModel: LinkPlayerViewModel
    
    var body: some View {
        switch viewModel.viewState {
        case .scanning:
            ZStack {
                CodeScannerView(codeTypes: [.qr], simulatedData: QRConstants.simulatedData, completion: viewModel.handleScan)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(Color(.lightColour))
                        }
                    }
                    .padding()
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
                Button {
                    viewModel.viewState = .scanning
                } label: {
                    Text("Try Again")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.darkColour))
                }
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
                Button {
                    viewModel.viewState = .scanning
                } label: {
                    Text("cancel")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.darkColour))
                }
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
                Button {
                    viewModel.viewState = .scanning
                } label: {
                    Text("Try Again")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(.darkColour))
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
    vm.viewState = .scanning
    
    return LinkPlayerView(viewModel: vm)
}
