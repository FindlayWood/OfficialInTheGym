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
            CodeScannerView(codeTypes: [.qr], simulatedData: QRConstants.simulatedData, completion: viewModel.handleScan)
        case .scanError:
            Text("Scan Error")
        case .loadingScan:
            VStack {
                Text("Loading Scan")
                ProgressView()
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
                Text("Linking")
                ProgressView()
            }
            
        case .success:
            VStack {
                Text("Success")
            }
            
        case .error:
            VStack {
                Text("Error")
            }
        }
    }
}

#Preview {
    LinkPlayerView(viewModel: LinkPlayerViewModel(scannerService: PreviewScannerService(),
                                                  clubModel: .example,
                                                  loader: PreviewPlayerLoader(),
                                                  playerModel: .example,
                                                  linkService: PreviewLinkPlayerService()))
}
