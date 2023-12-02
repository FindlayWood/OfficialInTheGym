//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 26/11/2023.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct AddPlayerQRView: View {
    
    @ObservedObject var viewModel: AddPlayerQRViewModel
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("Your QR Code")
                    Text("Display Name")
                    Text("UserName")
                }
                Spacer()
            }
            Image(uiImage: generateQRCode(from: viewModel.userID))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            HStack {
                Spacer()
                Text("If you want to join a club quickly have an admin of the club scan this QR code.")
                Spacer()
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    AddPlayerQRView(viewModel: AddPlayerQRViewModel(userService: PreviewCurrentUserService()))
}
