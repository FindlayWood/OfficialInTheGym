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
    var imageColours: [UIColor?] = [.goldColour, .lightColour, .goldColour]
    var titles: [String] = ["Elite Trainer Account", "Verified Account", "Premium Account"]
    var messages: [String] = ["This stamp is given to accounts who produce elite content for athletes. This stamp is only given out when an account's content has been thoroughly reviewed by our team and beleived to help produce elite athletes. This stamp is not easy to receive and denotes a great account to follow.",
                              "This stamp is given to accounts who have verified themselves as coaches of elite athletes or an elite athlete. This stamp denotes a great account to follow.",
                              "This stamp denotes a premium account."
    ]
    var body: some View {
        ScrollView {
            VStack {
                Image("stamp_icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                Text("Stamps")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ForEach (0..<3) { i in
                    StampSubview(imageName: imageNames[i],
                                 imageColour: imageColours[i],
                                 title: titles[i],
                                 message: messages[i])
                }
                Button {
                    dismissButtonCallBack.send(())
                } label: {
                    Text("Dismiss")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.darkColour))
                .cornerRadius(8)
                .padding()
            }
            .padding()
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
        VStack {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(imageColour ?? .systemYellow))
                .padding()
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(message)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
