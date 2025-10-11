import SwiftUI

struct DevicesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingPairModal = false
    @State private var isSearching = false
    
    // Mock paired devices
    @State private var pairedDevices = [
        Device(name: "Your Name's Apple Watch", type: .appleWatch, isConnected: true),
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
                            // Pair New Device Button
                            pairNewDeviceButton
                            
                            // History Section
                            historySection
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showingPairModal) {
            PairDeviceModal(isSearching: $isSearching)
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
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                Text("Devices")
                    .font(.custom("Noto Sans", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                
                Spacer()
                
                // Invisible spacer to balance the back button
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(Color.white)
        }
    }
    
    // MARK: - Pair New Device Button
    var pairNewDeviceButton: some View {
        Button(action: {
            showingPairModal = true
        }) {
            HStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color(red: 0.02, green: 0.33, blue: 0.18))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pair New Device")
                        .font(.custom("Noto Sans", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                    
                    Text("Connect a new health device")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                }
                
                Spacer()
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Pair Device Modal
struct PairDeviceModal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isSearching: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                HStack {
                    Text("Pair New Device")
                        .font(.custom("Noto Sans", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                            .frame(width: 30, height: 30)
                            .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 24)
                
                // Searching UI
                if isSearching {
                    VStack(spacing: 24) {
                        // Search Animation
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 4)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color(red: 0.36, green: 0.55, blue: 0.37), lineWidth: 4)
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isSearching)
                        }
                        
                        Text("Searching for Devices...")
                            .font(.custom("Noto Sans", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                        
                        Text("Make sure your device is ready to connect")
                            .font(.custom("Noto Sans", size: 14))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                            .multilineTextAlignment(.center)
                    }
                } else {
                    // Start Search Button
                    Button(action: {
                        isSearching = true
                        // Simulate search completion after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isSearching = false
                            dismiss()
                        }
                    }) {
                        Text("Start Search")
                            .font(.custom("Noto Sans", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.02, green: 0.33, blue: 0.18))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .background(Color.white)
        }
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
