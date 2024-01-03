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
            Text("Loading Scan")
        case let .gotUserProfile(model):
            List {
                
                Section {
                    VStack {
                        Text(model.displayName)
                        Text("@\(model.username)")
                    }
                } header: {
                    Text("User Model")
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.create()
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
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 2, leading: 2, bottom: 2, trailing: 2))
                
            }
        }
    }
}

#Preview {
    LinkPlayerView(viewModel: LinkPlayerViewModel(scannerService: PreviewScannerService(),
                                                  clubModel: .example,
                                                  loader: PreviewPlayerLoader(),
                                                  playerModel: .example,
                                                  creationService: PreviewPlayerCreationService()))
}
