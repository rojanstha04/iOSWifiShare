//
//  WiFiConnectionSheet.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//

import SwiftUI

struct WiFiConnectionSheet: View {
    let wifiInfo: WiFiInfo
    @Environment(\.dismiss) private var dismiss
    @State private var isConnecting = false
    @State private var connectionStatus = ""
    @StateObject private var networkManager = WiFiNetworkManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "wifi")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    Text("Connect to WiFi")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.top, 20)
                
                // Network Info
                VStack(spacing: 16) {
                    InfoRow(label: "Network Name", value: wifiInfo.networkName)
                    InfoRow(label: "Security Type", value: wifiInfo.securityType)
                    InfoRow(label: "Hidden Network", value: wifiInfo.isHidden ? "Yes" : "No")
                    
                    if !wifiInfo.password.isEmpty {
                        InfoRow(label: "Password", value: String(repeating: "•", count: wifiInfo.password.count))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                // Connection Status
                if !connectionStatus.isEmpty {
                    Text(connectionStatus)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Connect Button
                Button(action: connectToWiFi) {
                    HStack {
                        if isConnecting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isConnecting ? "Connecting..." : "Connect to Network")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isConnecting ? Color.gray : Color.blue)
                    )
                }
                .disabled(isConnecting)
                .padding(.horizontal)
                
                Text("Note: Due to iOS restrictions, you may need to manually connect to the network in Settings.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("WiFi Connection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
        .onAppear {
            // Save this network to history when the sheet appears
            networkManager.saveNetwork(wifiInfo)
        }
    }
    
    private func connectToWiFi() {
        isConnecting = true
        connectionStatus = "Attempting to connect..."
        
        // Note: iOS has restrictions on programmatically connecting to WiFi
        // This is a simplified implementation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isConnecting = false
            connectionStatus = "Please go to Settings > WiFi to complete the connection"
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
