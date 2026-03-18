//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AccountCreationHomeViewModel
    var colour: UIColor
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    ForEach(0..<7) { num in
                        RoundedRectangle(cornerRadius: 2)
                            .frame(maxWidth: .infinity)
                            .frame(height: 4)
                            .foregroundColor(num > viewModel.page ? .secondary : Color(colour))
                            .onTapGesture {
                                viewModel.page = num
                            }
                    }
                }
                .padding(.horizontal)
                TabView(selection: $viewModel.page) {
                    WelcomeView(colour: colour)
                        .tag(0)
                    UsernameView(viewModel: viewModel, colour: colour)
                        .tag(1)
                    DisplayNameView(viewModel: viewModel, colour: colour)
                        .tag(2)
                    BioView(viewModel: viewModel, colour: colour)
                        .tag(3)
                    AccountTypeView(viewModel: viewModel, colour: colour)
                        .tag(4)
                    ProfilePictureView(viewModel: viewModel, colour: colour)
                        .tag(5)
                    UploadView(viewModel: viewModel, colour: colour)
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                HStack {
                    if viewModel.page > 0 {
                        Button {
                            viewModel.page -= 1
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color(colour))
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    Spacer()
                    if viewModel.page == 6 {
                        Button {
                            viewModel.createAccount()
                        } label: {
                            Text("Create Account")
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(Color(colour).opacity(viewModel.canCreateAccount ? 1 : 0.3))
                                .clipShape(Capsule())
                                .shadow(radius: viewModel.canCreateAccount ? 4 : 0)
                        }
                        .disabled(!viewModel.canCreateAccount)
                    } else if viewModel.page == 0 {
                        VStack {
                            Button {
                                viewModel.page += 1
                            } label: {
                                Text("Get Started")
                                    .padding()
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(colour))
                                    .clipShape(Capsule())
                                    .shadow(radius: 4)
                            }
                            Button {
                                viewModel.signOutAction()
                            } label: {
                                Text("Sign Out")
                                    .font(.footnote.weight(.medium))
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        Button {
                            viewModel.page += 1
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color(colour))
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
            if viewModel.uploading {
                LoadingView(colour: colour)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: AccountCreationHomeViewModel(email: "", uid: "", callback: {}, signOutCallback: {}), colour: .blue)
    }
}
