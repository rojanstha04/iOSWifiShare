//
//  WiFiNetworkManager.swift
//  dailyutility
//
//  Created by Rojan Shrestha on 7/16/25.
//
import Foundation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork

class WiFiNetworkManager: ObservableObject {
    @Published var savedNetworks: [WiFiInfo] = []
    @Published var deviceNetworks: [WiFiInfo] = []
    @Published var currentNetwork: String? = nil
    @Published var isLoadingDeviceNetworks = false
    
    private let userDefaults = UserDefaults.standard
    private let savedNetworksKey = "SavedWiFiNetworks"
    
    init() {
        loadSavedNetworks()
        getCurrentNetwork()
        requestNetworkAccess()
    }
    
    // MARK: - Current Network Detection
    func getCurrentNetwork() {
        currentNetwork = getCurrentNetworkSSID()
    }
    
    private func getCurrentNetworkSSID() -> String? {
        var ssid: String?
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        
        return ssid
    }
    
    // MARK: - Device Networks (iOS 13+)
    func requestNetworkAccess() {
        if #available(iOS 13.0, *) {
            loadDeviceNetworks()
        } else {
            // Fallback for older iOS versions
            loadSampleNetworks()
        }
    }
    
    @available(iOS 13.0, *)
    private func loadDeviceNetworks() {
        isLoadingDeviceNetworks = true
        
        // For iOS 13+, we'll use a different approach since getConfiguredSSIDs
        // is not available in the public API
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingDeviceNetworks = false
            // Try to get current network and use it as a starting point
            if let currentSSID = self?.getCurrentNetworkSSID() {
                self?.processDeviceNetworks([currentSSID])
            } else {
                self?.loadKnownNetworks()
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func processDeviceNetworks(_ ssids: [String]) {
        var networks: [WiFiInfo] = []
        
        for ssid in ssids {
            // Since we can't get passwords from iOS, we'll create entries without passwords
            let network = WiFiInfo(
                networkName: ssid,
                password: "", // iOS doesn't allow reading saved passwords
                securityType: "WPA", // Default assumption
                isHidden: false,
                dateAdded: Date()
            )
            networks.append(network)
        }
        
        // Remove duplicates and sort
        let uniqueNetworks = networks.reduce(into: [String: WiFiInfo]()) { result, network in
            result[network.networkName] = network
        }.values.sorted { $0.networkName < $1.networkName }
        
        self.deviceNetworks = Array(uniqueNetworks)
        
        // If no networks found, load sample networks
        if deviceNetworks.isEmpty {
            loadSampleNetworks()
        }
    }
    
    // MARK: - Alternative method for known networks
    private func loadKnownNetworks() {
        // Since we can't reliably get all saved networks from iOS,
        // we'll focus on the current network and sample networks
        if let currentSSID = getCurrentNetworkSSID() {
            let currentNetwork = WiFiInfo(
                networkName: currentSSID,
                password: "", // iOS doesn't allow reading saved passwords
                securityType: "WPA", // Default assumption
                isHidden: false,
                dateAdded: Date()
            )
            deviceNetworks = [currentNetwork]
        } else {
            deviceNetworks = []
        }
        
        // Always load sample networks as fallback
        loadSampleNetworks()
    }
    
    // MARK: - Enhanced network detection
    func scanForNearbyNetworks() {
        // This is a more realistic approach for iOS
        // We'll simulate network discovery since iOS restricts actual WiFi scanning
        
        // Get current network
        if let currentSSID = getCurrentNetworkSSID() {
            let currentNetwork = WiFiInfo(
                networkName: currentSSID,
                password: "",
                securityType: "WPA",
                isHidden: false,
                dateAdded: Date()
            )
            
            // Update device networks with current network
            deviceNetworks = [currentNetwork]
        }
        
        // Note: In a real implementation, you might want to:
        // 1. Use Core Location to get location-based network suggestions
        // 2. Maintain a database of common network names
        // 3. Use machine learning to predict likely networks
        
        // For now, we'll use sample networks as demonstration
        if deviceNetworks.isEmpty {
            loadSampleNetworks()
        }
    }
    
    // MARK: - Network History Management
    func saveNetwork(_ wifiInfo: WiFiInfo) {
        // Remove existing network with same name to avoid duplicates
        savedNetworks.removeAll { $0.networkName == wifiInfo.networkName }
        
        // Add new network at the beginning
        savedNetworks.insert(wifiInfo, at: 0)
        
        // Keep only last 50 networks
        if savedNetworks.count > 50 {
            savedNetworks = Array(savedNetworks.prefix(50))
        }
        
        saveToDisk()
    }
    
    func deleteNetwork(_ wifiInfo: WiFiInfo) {
        savedNetworks.removeAll { $0.id == wifiInfo.id }
        deviceNetworks.removeAll { $0.id == wifiInfo.id }
        saveToDisk()
    }
    
    func clearAllNetworks() {
        savedNetworks.removeAll()
        saveToDisk()
    }
    
    func refreshDeviceNetworks() {
        getCurrentNetwork()
        scanForNearbyNetworks()
    }
    
    // MARK: - Combine all networks
    var allNetworks: [WiFiInfo] {
        var combined: [String: WiFiInfo] = [:]
        
        // Add device networks first
        for network in deviceNetworks {
            combined[network.networkName] = network
        }
        
        // Add saved networks (these might have passwords)
        for network in savedNetworks {
            if let existingNetwork = combined[network.networkName] {
                // If we have a saved network with a password, prefer it
                if !network.password.isEmpty {
                    combined[network.networkName] = network
                }
            } else {
                combined[network.networkName] = network
            }
        }
        
        return Array(combined.values).sorted { $0.dateAdded > $1.dateAdded }
    }
    
    // MARK: - Persistence
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedNetworks) {
            userDefaults.set(encoded, forKey: savedNetworksKey)
        }
    }
    
    private func loadSavedNetworks() {
        if let data = userDefaults.data(forKey: savedNetworksKey),
           let decoded = try? JSONDecoder().decode([WiFiInfo].self, from: data) {
            savedNetworks = decoded.sorted { $0.dateAdded > $1.dateAdded }
        }
    }
    
    // MARK: - Sample Networks (fallback)
    func loadSampleNetworks() {
        let sampleNetworks = [
            WiFiInfo(networkName: "Home WiFi", password: "", securityType: "WPA", isHidden: false, dateAdded: Date().addingTimeInterval(-86400)),
            WiFiInfo(networkName: "Office Network", password: "", securityType: "WPA", isHidden: false, dateAdded: Date().addingTimeInterval(-172800)),
            WiFiInfo(networkName: "Coffee Shop", password: "", securityType: "WPA", isHidden: false, dateAdded: Date().addingTimeInterval(-259200)),
            WiFiInfo(networkName: "Guest Network", password: "", securityType: "nopass", isHidden: false, dateAdded: Date().addingTimeInterval(-345600)),
            WiFiInfo(networkName: "iPhone Hotspot", password: "", securityType: "WPA", isHidden: false, dateAdded: Date().addingTimeInterval(-432000))
        ]
        
        // Add to device networks if empty
        if deviceNetworks.isEmpty {
            deviceNetworks = sampleNetworks
        }
        
        // Also add to saved networks if they don't exist
        for network in sampleNetworks {
            if !savedNetworks.contains(where: { $0.networkName == network.networkName }) {
                savedNetworks.append(network)
            }
        }
        
        savedNetworks.sort { $0.dateAdded > $1.dateAdded }
        saveToDisk()
    }
}
