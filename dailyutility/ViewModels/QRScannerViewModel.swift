//
//  QRScannerViewModel.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//

import SwiftUI

class QRScannerViewModel: ObservableObject {
    @Published var scannedCode: String?
    @Published var isScanning = false
    
    func startScanning() {
        isScanning = true
        scannedCode = nil
    }
    
    func stopScanning() {
        isScanning = false
    }
}
