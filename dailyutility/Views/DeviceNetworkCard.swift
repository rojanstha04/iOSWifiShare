//
//  DeviceNetworkCard.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//

import SwiftUI

struct DeviceNetworkCard: View {
    let network: WiFiInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: network.isHidden ? "eye.slash" : "wifi")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    if isFromDevice {
                        Image(systemName: "iphone")
                            .foregroundColor(.green)
                            .font(.system(size: 10))
                    }
                    
                    Image(systemName: securityIcon)
                        .foregroundColor(securityColor)
                        .font(.system(size: 12))
                }
                
                Text(network.networkName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack {
                    Text(network.securityType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(securityColor.opacity(0.1))
                        )
                    
                    Spacer()
                    
                    if !network.password.isEmpty {
                        Image(systemName: "key.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 8))
                    }
                }
                
                if isFromDevice {
                    Text("From device")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Text(timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(width: 160, height: 110)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFromDevice ? Color.green.opacity(0.05) : Color(.systemGray6))
                    .stroke(isFromDevice ? Color.green.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isFromDevice: Bool {
        // Check if this is a device network (no password typically means from device)
        return network.password.isEmpty && Calendar.current.isDateInToday(network.dateAdded)
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
