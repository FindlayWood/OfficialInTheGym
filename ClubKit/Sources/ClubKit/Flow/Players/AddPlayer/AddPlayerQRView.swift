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
    
    @State private var name = "Anonymous"
    @State private var emailAddress = "you@yoursite.com"
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        Image(uiImage: generateQRCode(from: "\(name)\n\(emailAddress)"))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
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
    AddPlayerQRView(viewModel: AddPlayerQRViewModel())
}
