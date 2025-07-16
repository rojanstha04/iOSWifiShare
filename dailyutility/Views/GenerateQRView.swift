import SwiftUI
import CoreImage.CIFilterBuiltins

struct GenerateQRView: View {
    @StateObject private var networkManager = WiFiNetworkManager()
    @State private var networkName = ""
    @State private var password = ""
    @State private var securityType = "WPA"
    @State private var isHidden = false
    @State private var showingShareSheet = false
    @State private var generatedQRImage: UIImage?
    @State private var showingNetworkHistory = false
    @State private var searchText = ""
    
    let securityTypes = ["WPA", "WEP", "nopass"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "wifi")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        Text("Generate WiFi QR Code")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Share your WiFi network easily")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Quick Access Section
                    if !networkManager.allNetworks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your Networks")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("From device settings & history")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("View All") {
                                    showingNetworkHistory = true
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Array(networkManager.allNetworks.prefix(5))) { network in
                                        DeviceNetworkCard(network: network) {
                                            selectNetwork(network)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Loading indicator
                    if networkManager.isLoadingDeviceNetworks {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading device networks...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // Current Network Detection
                    if let currentNetwork = networkManager.currentNetwork {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "wifi")
                                    .foregroundColor(.green)
                                Text("Currently Connected")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            Button(action: {
                                networkName = currentNetwork
                                // Note: We can't get the password of current network due to iOS restrictions
                                password = ""
                            }) {
                                HStack {
                                    Text(currentNetwork)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.1))
                                        .stroke(Color.green, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Manual Input Form
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manual Entry")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Network Name
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Network Name (SSID)")
                                    .font(.headline)
                                HStack {
                                    TextField("Enter WiFi network name", text: $networkName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                    
                                    if !networkManager.savedNetworks.isEmpty {
                                        Button(action: {
                                            showingNetworkHistory = true
                                        }) {
                                            Image(systemName: "clock")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password")
                                    .font(.headline)
                                SecureField("Enter WiFi password", text: $password)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            // Security Type
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Security Type")
                                    .font(.headline)
                                Picker("Security Type", selection: $securityType) {
                                    ForEach(securityTypes, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            // Hidden Network Toggle
                            Toggle("Hidden Network", isOn: $isHidden)
                                .font(.headline)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Generate Button
                    Button(action: generateQRCode) {
                        Text("Generate QR Code")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(networkName.isEmpty ? Color.gray : Color.blue)
                            )
                    }
                    .disabled(networkName.isEmpty)
                    .padding(.horizontal)
                    
                    // QR Code Display
                    if let qrImage = generatedQRImage {
                        VStack(spacing: 16) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            
                            Button(action: {
                                showingShareSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share QR Code")
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
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("WiFi QR Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Refresh Networks") {
                            networkManager.refreshDeviceNetworks()
                        }
                        Button("Load Sample Networks") {
                            networkManager.loadSampleNetworks()
                        }
                        Button("Clear History") {
                            networkManager.clearAllNetworks()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let qrImage = generatedQRImage {
                ShareSheet(items: [qrImage])
            }
        }
        .sheet(isPresented: $showingNetworkHistory) {
            NetworkHistoryView(networkManager: networkManager, onNetworkSelected: { network in
                selectNetwork(network)
                showingNetworkHistory = false
            })
        }
        .onAppear {
            networkManager.getCurrentNetwork()
        }
    }
    
    
    private func selectNetwork(_ network: WiFiInfo) {
        networkName = network.networkName
        password = network.password
        securityType = network.securityType
        isHidden = network.isHidden
    }
    
    private func generateQRCode() {
        let wifiString = createWiFiString()
        generatedQRImage = generateQRCode(from: wifiString)
        
        // Save this network to history
        let newNetwork = WiFiInfo(
            networkName: networkName,
            password: password,
            securityType: securityType,
            isHidden: isHidden
        )
        networkManager.saveNetwork(newNetwork)
    }
    
    private func createWiFiString() -> String {
        // WiFi QR code format: WIFI:T:WPA;S:networkname;P:password;H:false;;
        let hiddenString = isHidden ? "true" : "false"
        let securityString = securityType == "nopass" ? "nopass" : securityType
        let passwordString = securityType == "nopass" ? "" : password
        
        return "WIFI:T:\(securityString);S:\(networkName);P:\(passwordString);H:\(hiddenString);;"
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}
