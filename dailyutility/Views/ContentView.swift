
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GenerateQRView()
                .tabItem {
                    Image(systemName: "qrcode")
                    Text("Generate")
                }
                .tag(0)
            
            ScanQRView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("Scan")
                }
                .tag(1)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
