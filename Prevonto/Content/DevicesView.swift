// Devices page for the Prevonto app
import SwiftUI

struct DevicesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isSearching = false
    
    // Mock paired devices (When successfully implement paired devices tracking, replace this section of code)
    @State private var pairedDevices = [
        Device(name: "Your Name's Apple Watch", type: .appleWatch, isConnected: true)
    ]
    
    // Mock nearby devices (When successfully implement nearby devices tracking, replace this section of code)
    @State private var nearbyDevices = [
        Device(name: "User's Apple Watch", type: .appleWatch, isConnected: false),
        Device(name: "Speaker", type: .other, isConnected: false)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Devices Content
                    ScrollView {
                        VStack(spacing: 24) {
                            if isSearching {
                                searchProgressView
                            } else {
                                pairNewDeviceButton
                            }
                            
                            // History Section
                            historySection
                            
                            // Nearby Devices Section
                            nearbyDevicesSection
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Spacer()
                
                Text("Devices")
                    .font(.custom("Noto Sans", size: 28))
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                
                Spacer()
                
                // Invisible spacer to balance the back button
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 0)
            .background(Color.white)
        }
    }
    
    // MARK: - Pair New Device Button
    var pairNewDeviceButton: some View {
        Button(action: {
            startSearch()
        }) {
            HStack(spacing: 16) {
                Spacer()
                Text("Pair New Device")
                    .font(.custom("Noto Sans", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding(20)
            .background(Color(red: 0.01, green: 0.33, blue: 0.18))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Search Progress View
    @State private var searchProgress: Double = 0.0
    @State private var progressTimer: Timer?

    var searchProgressView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.36, green: 0.55, blue: 0.37).opacity(0.25), lineWidth: 40)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: searchProgress)
                    .stroke(Color(red: 0.36, green: 0.55, blue: 0.37), style: StrokeStyle(lineWidth: 40, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.1), value: searchProgress)
            }
            .padding(.bottom, 12)

            VStack(spacing: 8) {
                Text("Searching for Devices...")
                    .font(.custom("Noto Sans", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))

                Text("Make sure your device is ready to connect")
                    .font(.custom("Noto Sans", size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear { startSearchAnimation() }
        .onDisappear { stopSearchAnimation() }
    }
    
    private func startSearch() {
        isSearching = true
        searchProgress = 0.0
        startSearchAnimation()
        // Simulate 8-second search
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            stopSearchAnimation()
            isSearching = false
        }
    }

    private func startSearchAnimation() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let increment = 0.0125
            if searchProgress < 1.0 {
                searchProgress += increment
            }
        }
    }

    private func stopSearchAnimation() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - History Section
    var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(pairedDevices) { device in
                    DeviceRowView(device: device)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    
    // MARK: - Nearby Devices Section
    var nearbyDevicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nearby Devices")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(nearbyDevices) { device in
                    DeviceRowView(device: device)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Device Row Component
struct DeviceRowView: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: 16) {
            // Device Icon
            Image(systemName: device.iconName)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                .frame(width: 40, height: 40)
            
            // Device Info
            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                
                Text(device.isConnected ? "Connected" : "Not Connected")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(device.isConnected ? Color(red: 0.36, green: 0.55, blue: 0.37) : Color(red: 0.60, green: 0.60, blue: 0.60))
            }
            
            Spacer()
            
            // Connection Status
            Circle()
                .fill(device.isConnected ? Color(red: 0.36, green: 0.55, blue: 0.37) : Color(red: 0.85, green: 0.85, blue: 0.85))
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Device Model
struct Device: Identifiable {
    let id = UUID()
    let name: String
    let type: DeviceType
    let isConnected: Bool
    
    var iconName: String {
        switch type {
        case .appleWatch:
            return "applewatch"
        case .other:
            return "speaker.wave.2.fill"
        }
    }
}

enum DeviceType {
    case appleWatch
    case other
}

// MARK: - Preview
struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
    }
}
