//
//  ScanQRView.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//

import SwiftUI

struct ScanQRView: View {
    @StateObject private var qrScanner = QRScannerViewModel()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingConnectionSheet = false
    @State private var scannedWiFiInfo: WiFiInfo?
    
    var body: some View {
        NavigationView {
            VStack {
                if qrScanner.isScanning {
                    QRScannerView(viewModel: qrScanner)
                        .onReceive(qrScanner.$scannedCode) { code in
                            if let code = code {
                                handleScannedCode(code)
                            }
                        }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Scan WiFi QR Code")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Point your camera at a WiFi QR code to automatically connect")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            qrScanner.startScanning()
                        }) {
                            Text("Start Scanning")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                )
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                
                if qrScanner.isScanning {
                    Button(action: {
                        qrScanner.stopScanning()
                    }) {
                        Text("Stop Scanning")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingConnectionSheet) {
            if let wifiInfo = scannedWiFiInfo {
                WiFiConnectionSheet(wifiInfo: wifiInfo)
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        qrScanner.stopScanning()
        
        if let wifiInfo = parseWiFiQRCode(code) {
            scannedWiFiInfo = wifiInfo
            showingConnectionSheet = true
        } else {
            alertTitle = "Invalid QR Code"
            alertMessage = "This QR code doesn't contain valid WiFi information."
            showingAlert = true
        }
    }
    
    private func parseWiFiQRCode(_ code: String) -> WiFiInfo? {
        // Parse WiFi QR code format: WIFI:T:WPA;S:networkname;P:password;H:false;;
        guard code.hasPrefix("WIFI:") else { return nil }
        
        let components = code.components(separatedBy: ";")
        var networkName = ""
        var password = ""
        var securityType = "WPA"
        var isHidden = false
        
        for component in components {
            if component.hasPrefix("S:") {
                networkName = String(component.dropFirst(2))
            } else if component.hasPrefix("P:") {
                password = String(component.dropFirst(2))
            } else if component.hasPrefix("T:") {
                securityType = String(component.dropFirst(2))
            } else if component.hasPrefix("H:") {
                isHidden = String(component.dropFirst(2)).lowercased() == "true"
            }
        }
        
        guard !networkName.isEmpty else { return nil }
        
        return WiFiInfo(
            networkName: networkName,
            password: password,
            securityType: securityType,
            isHidden: isHidden
        )
    }
}
