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
    let vm = QRScannerViewModel(scannerService: PreviewScannerService(), clubModel: .example, loader: PreviewPlayerLoader(), teamLoader: PreviewTeamLoader(), creationService: PreviewPlayerCreationService())
    vm.viewState = .scanning
    return QRScannerView(viewModel: vm)
//    QRScannerView(viewModel: .init(scannerService: PreviewScannerService(),
//                                   clubModel: .example,
//                                   loader: PreviewPlayerLoader(),
//                                   teamLoader: PreviewTeamLoader(),
//                                   creationService: PreviewPlayerCreationService()))
}
