//
//  SignUpAccountSelectionView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 06/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SignUpAccountSelectionView: View {
    @State var selectedAccountType: AccountType?
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Select Account Type")
                    .font(.title)
                    .foregroundColor(.secondary)
                Spacer()
            }
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(selectedAccountType == .coach ? .darkColour : .lightColour))
                    Button {
                        selectedAccountType = .coach
                    } label: {
                        VStack {
                            Image("coach_icon")
                            Text("Coach")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(selectedAccountType == .player ? .darkColour : .lightColour))
                    Button {
                        selectedAccountType = .player
                    } label: {
                        VStack {
                            Image("player_icon")
                            Text("Player")
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
            .padding()
            if selectedAccountType != nil {
                Button {
                    
                } label: {
                    Text("Continue")
                }
            }
        }
    }
}

struct SignUpAccountSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpAccountSelectionView()
    }
}
