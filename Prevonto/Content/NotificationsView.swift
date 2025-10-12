// Notifications Page for Prevonto app
import SwiftUI

// Shared state manager for notification settings
class NotificationSettings: ObservableObject {
    @Published var pushNotifications: Bool = true
    @Published var heartRate: Bool = true
    @Published var stepsAndActivity: Bool = true
    
    // Read-only toggles (grayed out)
    let bodyMetrics: Bool = false
    let bloodGlucose: Bool = false
    let spo2: Bool = false
    let mood: Bool = false
    let weight: Bool = false
    let trackers: Bool = false
    let medication: Bool = false
}

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var settings = NotificationSettings()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Notifications Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Push Notifications Section
                            pushNotificationsSection
                            
                            // Body Metrics Section
                            bodyMetricsSection
                            
                            // Trackers Section
                            trackersSection
                            
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
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                Text("Notifications")
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
    
    // MARK: - Push Notifications Section
    var pushNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Push Notifications")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                NotificationToggleRow(
                    title: "Push Notifications",
                    isOn: $settings.pushNotifications,
                    isEnabled: true
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Body Metrics Section
    var bodyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Body Metrics")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                NotificationToggleRow(
                    title: "Body Metrics",
                    isOn: .constant(settings.bodyMetrics),
                    isEnabled: false
                )
                
                Divider().padding(.leading, 16)
                
                NotificationToggleRow(
                    title: "Blood Glucose",
                    isOn: .constant(settings.bloodGlucose),
                    isEnabled: false
                )
                
                Divider().padding(.leading, 16)
                
                NotificationToggleRow(
                    title: "SpO2",
                    isOn: .constant(settings.spo2),
                    isEnabled: false
                )
                
                Divider().padding(.leading, 16)
                
                NotificationToggleRow(
                    title: "Heart Rate",
                    isOn: $settings.heartRate,
                    isEnabled: true
                )
                
                Divider().padding(.leading, 16)
                
                NotificationToggleRow(
                    title: "Mood",
                    isOn: .constant(settings.mood),
                    isEnabled: false
                )
                
                Divider().padding(.leading, 16)
                
                NotificationToggleRow(
                    title: "Weight",
                    isOn: .constant(settings.weight),
                    isEnabled: false
                )
                
                Divider().padding(.leading, 16)
                
                NotificationToggleRow(
                    title: "Steps & Activity",
                    isOn: $settings.stepsAndActivity,
                    isEnabled: true
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Trackers Section
    var trackersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trackers")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                NotificationToggleRow(
                    title: "Trackers",
                    isOn: .constant(settings.trackers),
                    isEnabled: false
                )
                
                Divider().padding(.leading, 16)
                
                NotificationToggleRow(
                    title: "Medication",
                    isOn: .constant(settings.medication),
                    isEnabled: false
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Notification Toggle Row Component
struct NotificationToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.medium)
                .foregroundColor(isEnabled ? Color(red: 0.404, green: 0.420, blue: 0.455) : Color(red: 0.60, green: 0.60, blue: 0.60))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(CustomToggleStyle(isEnabled: isEnabled))
                .disabled(!isEnabled)
                .onChange(of: isOn) { oldValue, newValue in
                    handleToggleChange(title: title, newValue: newValue)
                }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    private func handleToggleChange(title: String, newValue: Bool) {
        if title == "Heart Rate" {
            // Update dashboard heart rate visibility
            UserDefaults.standard.set(newValue, forKey: "showHeartRate")
        } else if title == "Steps & Activity" {
            // Update dashboard activity rings visibility
            UserDefaults.standard.set(newValue, forKey: "showStepsActivity")
        } else if title == "Push Notifications" {
            // Handle push notifications toggle
            // Placeholder for future push notification implementation
        }
    }
}

// MARK: - Custom Toggle Style
struct CustomToggleStyle: ToggleStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 50, height: 30)
                .foregroundColor(
                    isEnabled ?
                    (configuration.isOn ? Color(red: 0.36, green: 0.55, blue: 0.37) : Color(red: 0.85, green: 0.85, blue: 0.85)) :
                    Color(red: 0.90, green: 0.90, blue: 0.90)
                )
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .onTapGesture {
                    if isEnabled {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}

// MARK: - Preview
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
