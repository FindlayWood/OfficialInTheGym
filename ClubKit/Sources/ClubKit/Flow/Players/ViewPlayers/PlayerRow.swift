//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import SwiftUI

struct PlayerRow: View {
    
    @State private var profileImage: UIImage?
    let model: RemotePlayerModel
    let imageCache: ImageCache
    var selectable: Bool = false
    var selected: Bool = false
    
    var body: some View {
        HStack(alignment: .bottom) {
            if let profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(.secondary)
                        .frame(width: 50, height: 50)
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
            VStack(alignment: .leading) {
                Text(model.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(positionString)
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if selectable {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(Color(.darkColour))
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            imageCache.getImage(for: ImageConstants.playerPath(model.id, in: model.clubID)) { image in
                self.profileImage = image
            }
        }
    }
    
    var positionString: String {
        var string = ""
        for position in model.positions {
            string.append(position.title)
            string.append(", ")
        }
        string.removeLast(2)
        return string
    }
}

struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        PlayerRow(model: .example, imageCache: PreviewImageCache())
    }
}
