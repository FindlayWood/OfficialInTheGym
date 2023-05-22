//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import SwiftUI

struct ClubRow: View {
    var model: RemoteClubModel
    var body: some View {
        HStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(model.clubName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if model.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color(.darkColour))
                        }
                        Spacer()
                    }
                    Text(model.tagline)
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
//                HStack(alignment: .top) {
//                    VStack(alignment: .leading) {
//                        Text(model.clubName)
//                            .font(.title.bold())
//                            .foregroundColor(.primary)
//                        Text(model.tagline)
//                            .font(.footnote.bold())
//                            .foregroundColor(.secondary)
//                    }
//                    if model.verified {
//                        Image(systemName: "checkmark.seal.fill")
//                            .foregroundColor(Color(.darkColour))
//                    }
//                    Spacer()
//                }
                Rectangle()
                    .fill(.black)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                HStack {
                    Image(systemName: "shield.fill")
                    Text(model.teamCount, format: .number)
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "person.3.fill")
                    Text(model.athleteCount, format: .number)
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                }
                .foregroundColor(Color(.darkColour))
                .padding(.vertical)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 1)
        )
    }
}

struct ClubRow_Previews: PreviewProvider {
    static var previews: some View {
        ClubRow(model: .example)
    }
}
