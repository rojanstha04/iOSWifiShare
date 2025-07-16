# QR WiFi - WiFi QR Code Generator & Scanner

A modern iOS app built with SwiftUI that makes WiFi sharing effortless through QR codes. Generate QR codes for your WiFi networks and scan codes from others to quickly connect.

## Features

### 🎯 Core Functionality
- **QR Code Generation**: Create QR codes for any WiFi network
- **QR Code Scanning**: Scan QR codes from camera, photo library, or manual input
- **Network History**: Automatic saving of all networks for quick access
- **Current Network Detection**: Auto-detect and use currently connected network
- **Multiple Input Methods**: Camera, photo library, clipboard, and manual text entry

### 📱 User Experience
- **Clean SwiftUI Interface**: Modern, intuitive design
- **Quick Access Cards**: Horizontal scrollable network cards
- **Smart Search**: Search through network history
- **Copy & Share**: Easy credential copying and QR code sharing
- **Step-by-Step Guide**: Manual connection instructions for iOS limitations

### 🔒 Security & Privacy
- **Local Storage**: All data stored locally using UserDefaults
- **No Cloud Dependency**: Complete offline functionality
- **Secure Network Parsing**: Safe QR code validation and parsing
- **User-Controlled Data**: Full control over saved networks

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+
- Camera access for QR scanning
- Photo library access for image scanning

## Installation

### Prerequisites
1. macOS with Xcode installed
2. iOS Developer Account (for device testing)
3. iOS device for camera functionality testing

### Setup Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/qr-wifi.git
   cd qr-wifi
   ```

2. Open the project in Xcode:
   ```bash
   open QRWiFi.xcodeproj
   ```

3. Configure your development team in Xcode:
   - Select your project in the navigator
   - Go to Signing & Capabilities
   - Select your development team

4. Add required permissions to `Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>This app needs camera access to scan WiFi QR codes</string>
   
   <key>NSPhotoLibraryUsageDescription</key>
   <string>This app needs photo library access to scan QR codes from saved images</string>
   ```

5. Build and run the project on your device

## Project Structure

```
QRWiFi/
├── App.swift                          # Main app entry point
├── ContentView.swift                  # Root tab view
├── Views/
│   ├── GenerateQRView.swift          # QR code generation interface
│   ├── ScanQRView.swift              # QR code scanning interface
│   ├── WiFiConnectionSheet.swift     # Network connection details
│   ├── QRScannerView.swift           # Camera scanner wrapper
│   ├── NetworkCard.swift             # Network preview cards
│   ├── DeviceNetworkCard.swift       # Enhanced network cards
│   ├── NetworkHistoryView.swift      # Full network history
│   ├── ConnectionInstructionsView.swift # Manual connection guide
│   ├── ImagePicker.swift             # Photo library picker
│   └── ManualQRInputView.swift       # Manual text input
├── ViewModels/
│   └── QRScannerViewModel.swift      # Scanner state management
├── Models/
│   └── WiFiInfo.swift                # Network data model
├── Managers/
│   └── WiFiNetworkManager.swift      # Network persistence & management
├── Controllers/
│   └── QRScannerViewController.swift # Camera controller
├── Utils/
│   ├── ShareSheet.swift              # iOS sharing interface
│   └── QRCodeDetector.swift          # Image QR detection
├── Info.plist                        # App permissions & configuration
└── Assets.xcassets                   # App icons & images
```

## Usage

### Generating QR Codes
1. Open the **Generate** tab
2. Select a network from your history or enter details manually
3. Tap **Generate QR Code**
4. Share the QR code with others

### Scanning QR Codes
1. Open the **Scan** tab
2. Choose your scanning method:
   - **Camera**: Point at QR code
   - **Photo Library**: Select saved image
   - **Manual Input**: Paste QR code text
3. Review network details
4. Follow connection instructions

### Network Management
- All networks are automatically saved to history
- Search through saved networks
- Delete individual networks or clear all
- Export network information

## Technical Details

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **UserDefaults**: Local data persistence

### Key Components
- **WiFiNetworkManager**: Handles network CRUD operations
- **QRScannerViewController**: Camera and QR detection
- **QRCodeDetector**: Image-based QR code detection using Vision framework
- **NetworkExtension**: Limited auto-connection attempts

### QR Code Format
The app uses the standard WiFi QR code format:
```
WIFI:T:WPA;S:NetworkName;P:Password;H:false;;
```

Where:
- `T`: Security type (WPA, WEP, nopass)
- `S`: Network name (SSID)
- `P`: Password
- `H`: Hidden network (true/false)

## iOS Limitations

### What Works
- ✅ Current network detection
- ✅ QR code generation and scanning
- ✅ Network history management
- ✅ Manual connection guidance

### iOS Restrictions
- ❌ Cannot access saved WiFi passwords from device
- ❌ Cannot automatically connect to networks (limited success)
- ❌ Cannot list all saved networks from device settings
- ❌ Requires manual connection for most networks

### Workarounds Implemented
- **NEHotspotConfiguration**: Attempts auto-connection (limited success)
- **Manual Instructions**: Step-by-step connection guide
- **Settings Deep Link**: Direct users to WiFi settings
- **Copy Functions**: Easy credential copying

## Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Commit: `git commit -m 'Add amazing feature'`
5. Push: `git push origin feature/amazing-feature`
6. Open a Pull Request

### Code Style
- Follow Swift naming conventions
- Use SwiftUI best practices
- Add comments for complex logic
- Keep functions focused and small

### Testing
- Test on actual iOS devices (camera functionality)
- Test with various QR code sources
- Verify network history persistence
- Test edge cases and error handling

## Known Issues

1. **Auto-connection limitations**: iOS security restrictions prevent reliable auto-connection
2. **Enterprise networks**: WPA2-Enterprise networks may not work with auto-connection
3. **Captive portals**: Hotel/public WiFi with login pages require manual connection
4. **iOS version differences**: Some features require iOS 13+

## Future Enhancements

### Planned Features
- [ ] iCloud sync for network history
- [ ] Network strength indicators
- [ ] Batch QR code generation
- [ ] Network categories/folders
- [ ] Export to various formats
- [ ] Dark mode improvements

### Technical Improvements
- [ ] Core Data migration for better persistence
- [ ] Widget support for quick access
- [ ] Shortcuts app integration
- [ ] Apple Watch companion app

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Privacy Policy

This app:
- Stores all data locally on your device
- Does not collect or transmit personal information
- Does not use analytics or tracking
- Requires only necessary permissions (camera, photo library)

## Support

### Troubleshooting
- **Camera not working**: Check camera permissions in Settings
- **QR codes not scanning**: Ensure good lighting and steady hands
- **Auto-connection fails**: Use manual connection guide
- **Network not appearing**: Try refreshing or manual entry

### Contact
- Create an issue on GitHub
- Email: rojanstha04@gmail.com

## Acknowledgments

- Apple's SwiftUI framework
- Vision framework for QR code detection
- NetworkExtension for connection attempts
- iOS developer community for best practices

---

**Made with ❤️ for the iOS community**
