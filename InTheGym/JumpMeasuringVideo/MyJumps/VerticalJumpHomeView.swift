//
//  VerticalJumpHomeView.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct VerticalJumpHomeView: View {
    
    @ObservedObject var viewModel: MyJumpsViewModel
    
    var body: some View {
        List {
            HStack {
                Spacer()
                VStack {
                    Image("jump_icon")
                        .resizable()
                        .frame(width: 60, height: 60)
                    Text("Welcome to the vertical jump measurement. Here you can measure the height of your vertical jump. Save jumps to the database to keep track of your jump history.")
                        .font(.body.weight(.medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
            
            
            Section {
                Button {
                    viewModel.action(.recordNewJump)
                } label: {
                    Text("Record New Jump")
                }
                .disabled(viewModel.isLoading)
            }
            
            
            Section {
                Button {
                    viewModel.action(.previousJumps)
                } label: {
                    Text("My Jumps")
                }
            }
            
            Section {
                Button {
                    viewModel.action(.help)
                } label: {
                    HStack {
                        Text("Help")
                    }
                }
            }
        }
        .task {
            await viewModel.loadMaxJump()
        }
    }
}

struct VerticalJumpHomeView_Previews: PreviewProvider {
    static var previews: some View {
        VerticalJumpHomeView(viewModel: MyJumpsViewModel())
    }
}

