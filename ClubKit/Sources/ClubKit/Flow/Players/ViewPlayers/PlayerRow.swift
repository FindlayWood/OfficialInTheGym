//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import SwiftUI

struct PlayerRow: View {
    
    var model: RemotePlayerModel
    
    var body: some View {
        HStack(alignment: .bottom) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(.secondary)
                    .frame(width: 50, height: 50)
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.title)
            }
            VStack(alignment: .leading) {
                Text(model.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(positionString)
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
            }
            Spacer()
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
        PlayerRow(model: .example)
    }
}
