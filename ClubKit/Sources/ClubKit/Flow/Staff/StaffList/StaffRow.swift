//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import SwiftUI

struct StaffRow: View {
    
    let model: RemoteStaffModel
    var selectable: Bool = false
    var selected: Bool = false
    
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
                Text(model.role.rawValue)
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
    }
}

#Preview {
    StaffRow(model: .example)
}
