//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 26/11/2023.
//

import SwiftUI

struct QRScannerView: View {
    
    @ObservedObject var viewModel: QRScannerViewModel
    
    var body: some View {
        switch viewModel.viewState {
        case .scanning:
            CodeScannerView(codeTypes: [.qr], simulatedData: QRConstants.simulatedData, completion: viewModel.handleScan)
        case .scanError:
            Text("Scan Error")
        case .loadingScan:
            Text("Loading Scan")
        case .gotUserProfile(_):
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
                            await viewModel.create()
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
        }
    }
}

#Preview {
    QRScannerView(viewModel: .init(scannerService: PreviewScannerService(),
                                   clubModel: .example,
                                   loader: PreviewPlayerLoader(),
                                   teamLoader: PreviewTeamLoader(),
                                   creationService: PreviewPlayerCreationService()))
}
