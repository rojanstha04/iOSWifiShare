//
//  NetworkHistoryView.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//

import SwiftUI

struct NetworkHistoryView: View {
    @ObservedObject var networkManager: WiFiNetworkManager
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    let onNetworkSelected: (WiFiInfo) -> Void
    
    var filteredNetworks: [WiFiInfo] {
        let networks = networkManager.allNetworks
        if searchText.isEmpty {
            return networks
        } else {
            return networks.filter { network in
                network.networkName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search networks...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                if filteredNetworks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? "No Saved Networks" : "No Networks Found")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text(searchText.isEmpty ? "Networks you generate QR codes for will appear here" : "Try a different search term")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if searchText.isEmpty {
                            Button("Refresh Device Networks") {
                                networkManager.refreshDeviceNetworks()
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .padding(.bottom, 8)
                            
                            Button("Load Sample Networks") {
                                networkManager.loadSampleNetworks()
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredNetworks) { network in
                            NetworkHistoryRow(network: network) {
                                onNetworkSelected(network)
                            }
                        }
                        .onDelete(perform: deleteNetworks)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Network History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Menu {
                    Button("Clear All", role: .destructive) {
                        networkManager.clearAllNetworks()
                    }
                    Button("Load Sample Networks") {
                        networkManager.loadSampleNetworks()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            )
        }
    }
    
    private func deleteNetworks(at offsets: IndexSet) {
        for index in offsets {
            networkManager.deleteNetwork(filteredNetworks[index])
        }
    }
}

struct NetworkHistoryRow: View {
    let network: WiFiInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Network Icon
                VStack {
                    Image(systemName: network.isHidden ? "eye.slash" : "wifi")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                    
                    Image(systemName: securityIcon)
                        .font(.system(size: 12))
                        .foregroundColor(securityColor)
                }
                .frame(width: 40)
                
                // Network Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(network.networkName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(network.securityType)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(securityColor)
                            )
                        
                        if network.isHidden {
                            Text("Hidden")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.orange)
                                )
                        }
                        
                        Spacer()
                        
                        Text(timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var securityIcon: String {
        switch network.securityType {
        case "WPA":
            return "lock.fill"
        case "WEP":
            return "lock"
        case "nopass":
            return "lock.open"
        default:
            return "lock.fill"
        }
    }
    
    private var securityColor: Color {
        switch network.securityType {
        case "WPA":
            return .green
        case "WEP":
            return .orange
        case "nopass":
            return .red
        default:
            return .green
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: network.dateAdded, relativeTo: Date())
    }
}
