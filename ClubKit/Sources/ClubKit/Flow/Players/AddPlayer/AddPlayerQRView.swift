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
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        Text(viewModel.displayName)
                            .font(.headline)
                        Text("@")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color.secondary)
                        + Text(viewModel.username)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white.cornerRadius(12)
                    .shadow(radius: 2, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.darkColour), lineWidth: 1.0)
                )
                .padding()
                
                
                VStack {
                    Image(uiImage: generateQRCode(from: viewModel.qrCodeString))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                        .padding(.vertical)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.cornerRadius(12)
                    .shadow(radius: 2, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.darkColour), lineWidth: 1.0)
                )
                .padding()
                
                
                HStack {
                    Spacer()
                    Text("If you want to join a club quickly have an admin of the club scan this QR code.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding()
                .background(Color.white.cornerRadius(12)
                    .shadow(radius: 2, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.darkColour), lineWidth: 1.0)
                )
                .padding()
            }
            .frame(maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
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
