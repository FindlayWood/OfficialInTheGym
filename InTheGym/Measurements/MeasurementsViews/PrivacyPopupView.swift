//
//  PrivacyPopupView.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PrivacyPopupView: View {
    
    @ObservedObject var viewModel: MyMeasurementsViewModel
    @Binding var isPrivate: Bool
    let privacyOptions: [Bool] = [false, true]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack(alignment: .leading, spacing: 8) {
                Text("Privacy Settings")
                    .font(.largeTitle.bold())
                Text("Measurements are kept private by default and not shared with anyone other than yourself (not even coaches). You still get the exact same benefits from the performance monitor with private measurements. However, we understand that some users enjoy sharing this information and would like to make their measurements public.")
                    .font(.body.weight(.medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                Picker("Measurements", selection: $isPrivate) {
                    ForEach(privacyOptions, id: \.self) {
                        Text($0 ? "Private" : "Public")
                    }
                }
                .pickerStyle(.segmented)
                HStack {
                    Spacer()
                    Image(systemName: isPrivate ? "lock.fill"  : "globe.asia.australia.fill")
                        .foregroundColor(Color(.darkColour))
                        .onTapGesture {
                            isPrivate.toggle()
                        }
                    Spacer()
                }
                Button {
                    Task {
                        await viewModel.upload()
                    }
                } label: {
                    Text("Upload")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.darkColour))
                        .cornerRadius(8)
                        .padding()
                }
                Button {
                    viewModel.showingPopover = false
                } label: {
                    Text("cancel")
                        .fontWeight(.light)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 2))
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
