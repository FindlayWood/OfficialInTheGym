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
                HStack {
                    ForEach(model.positions, id: \.self) { position in
                        Text(position.title)
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
    }
}

struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        PlayerRow(model: .example)
    }
}
