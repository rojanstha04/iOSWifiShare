//
//  WiFiInfo.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//

import Foundation

struct WiFiInfo: Identifiable, Codable {
    let id = UUID()
    let networkName: String
    let password: String
    let securityType: String
    let isHidden: Bool
    let dateAdded: Date
    
    init(networkName: String, password: String, securityType: String, isHidden: Bool, dateAdded: Date = Date()) {
        self.networkName = networkName
        self.password = password
        self.securityType = securityType
        self.isHidden = isHidden
        self.dateAdded = dateAdded
    }
}
