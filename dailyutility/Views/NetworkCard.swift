//
//  NetworkCard.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//

import SwiftUI

struct NetworkCard: View {
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
                    
                    Image(systemName: securityIcon)
                        .foregroundColor(securityColor)
                        .font(.system(size: 12))
                }
                
                Text(network.networkName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(network.securityType)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(securityColor.opacity(0.1))
                    )
            }
            .padding()
            .frame(width: 160, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
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
