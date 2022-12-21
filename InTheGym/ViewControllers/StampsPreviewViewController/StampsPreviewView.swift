//
//  StampsPreviewView.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI
import Combine

struct StampsPreviewView: View {
    var dismissButtonCallBack = PassthroughSubject<Void,Never>()
    var imageNames: [String] = ["checkmark.seal.fill", "checkmark.seal.fill", "crown.fill"]
    var imageColours: [UIColor] = [.goldColour, .lightColour, .goldColour]
    var titles: [String] = ["Elite Trainer Account", "Verified Account", "Premium Account"]
    var messages: [String] = ["This stamp is given to accounts who produce elite content for athletes. This stamp is only given out when an account's content has been thoroughly reviewed by our team and beleived to help produce elite athletes. This stamp is not easy to receive and denotes a great account to follow.",
                              "This stamp is given to accounts who have verified themselves as coaches of elite athletes or an elite athlete. This stamp denotes a great account to follow.",
                              "This stamp denotes a premium account."
    ]
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Stamps give an extra bit of information about accounts. They are only handed out by InTheGym after putting the account through a verification process.")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    ForEach (0..<3) { i in
                        StampSubview(imageName: imageNames[i],
                                     imageColour: imageColours[i],
                                     title: titles[i],
                                     message: messages[i])
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(colors: [Color.white, Color.white, Color.white, Color(.darkColour)], startPoint: .top, endPoint: .bottom)
            )
            .navigationTitle("Stamps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismissButtonCallBack.send(())
                    } label: {
                        Text("Dismiss")
                            .fontWeight(.bold)
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
        }
    }
}

struct StampsPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        StampsPreviewView()
    }
}

struct StampSubview: View {
    var imageName: String
    var imageColour: UIColor?
    var title: String
    var message: String
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(imageColour ?? .systemYellow))
                .padding()
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .background(Color(.darkColour))
                    .cornerRadius(4)
                    .padding(.bottom, 4)
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 2)
        )
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
