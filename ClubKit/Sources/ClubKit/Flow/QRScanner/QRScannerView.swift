//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 26/11/2023.
//

import SwiftUI

struct QRScannerView: View {
    
    @ObservedObject var viewModel: QRScannerViewModel
    
    var body: some View {
        switch viewModel.viewState {
        case .scanning:
            CodeScannerView(codeTypes: [.qr], simulatedData: "", completion: viewModel.handleScan)
        case .scanError:
            Text("Scan Error")
        case .loadingScan:
            Text("Loading Scan")
        case .gotPlayerUID(_):
            Text("Got Player Model")
        case .loadingUserProfile:
            Text("Loading User Profile")
        case .gotUserProfile(_):
            Text("Got User Profile")
        case .loadingPlayerCreation:
            Text("Loading Player Creation")
        case .playerCreationSuccess:
            Text("Player Creation Success")
        case .playerCreationError:
            Text("Player Creation Error")
        
        }
        
    }
}

#Preview {
    QRScannerView(viewModel: QRScannerViewModel(scannerService: PreviewScannerService()))
}
