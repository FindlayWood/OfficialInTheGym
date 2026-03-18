//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import SwiftUI

struct CreateStaffView: View {
    
    @ObservedObject var viewModel: CreateStaffViewModel
    
    var body: some View {
        ZStack {
            List {
                
                Section {
                    VStack(alignment: .leading) {
                        Text("Create New Staff")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                        Text("Creating a new staff member will add them to them to the club. They can then be added and removed from team's within the club as you wish. If the staff member already has an InTheGym account then you can use QR code to add them immediately and they can get access through their account. You can link created staff members with any InTheGym account at a later date.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                }
                
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
                    Picker("What is their role?", selection: $viewModel.role) {
                        ForEach(StaffRoles.allCases, id: \.self) { role in
                            Text(role.rawValue)
                                .tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Your Role")
                }
                
                Section {
                    Toggle("Are they an Admin?", isOn: $viewModel.isAdmin)
                } header: {
                    Text("Admin")
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
                    Button {
                        Task {
                            await viewModel.create()
                        }
                    } label: {
                        Text("Create Staff Member")
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
                        Text("Created New Player")
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
        .onAppear {
            viewModel.loadTeams()
        }
    }
}

#Preview {
    CreateStaffView(viewModel: .init(clubModel: .example, teamLoader: PreviewTeamLoader(), creationService: PreviewStaffService()))
}
