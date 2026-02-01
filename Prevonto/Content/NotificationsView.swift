// Notifications Page for Prevonto app
// Users can change what gets displayed in the Dashboard page with these toggle buttons here.
import SwiftUI

// Shared state manager for notification settings
class NotificationSettings: ObservableObject {
    @Published var pushNotifications: Bool = true {
        didSet { UserDefaults.standard.set(pushNotifications, forKey: "pushNotifications") }
    }
    @Published var heartRate: Bool = true {
        didSet { UserDefaults.standard.set(heartRate, forKey: "showHeartRate") }
    }
    @Published var stepsAndActivity: Bool = true {
        didSet { UserDefaults.standard.set(stepsAndActivity, forKey: "showStepsActivity") }
    }
    @Published var bloodPressure: Bool = true {
        didSet { UserDefaults.standard.set(bloodPressure, forKey: "showBloodPressure") }
    }
    @Published var bloodGlucose: Bool = true {
        didSet { UserDefaults.standard.set(bloodGlucose, forKey: "showBloodGlucose") }
    }
    @Published var spo2: Bool = true {
        didSet { UserDefaults.standard.set(spo2, forKey: "showSpO2") }
    }
    @Published var moodTracker: Bool = true {
        didSet { UserDefaults.standard.set(moodTracker, forKey: "showMoodTracker") }
    }
    @Published var weight: Bool = true {
        didSet { UserDefaults.standard.set(weight, forKey: "showWeight") }
    }
    @Published var medicationLog: Bool = true {
        didSet { UserDefaults.standard.set(medicationLog, forKey: "showMedicationLog") }
    }
    
    init() {
        // Load saved settings
        pushNotifications = UserDefaults.standard.object(forKey: "pushNotifications") as? Bool ?? true
        heartRate = UserDefaults.standard.object(forKey: "showHeartRate") as? Bool ?? true
        stepsAndActivity = UserDefaults.standard.object(forKey: "showStepsActivity") as? Bool ?? true
        bloodPressure = UserDefaults.standard.object(forKey: "showBloodPressure") as? Bool ?? true
        bloodGlucose = UserDefaults.standard.object(forKey: "showBloodGlucose") as? Bool ?? true
        spo2 = UserDefaults.standard.object(forKey: "showSpO2") as? Bool ?? true
        moodTracker = UserDefaults.standard.object(forKey: "showMoodTracker") as? Bool ?? true
        weight = UserDefaults.standard.object(forKey: "showWeight") as? Bool ?? true
        medicationLog = UserDefaults.standard.object(forKey: "showMedicationLog") as? Bool ?? true
    }
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
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.primaryGreen)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Spacer()
                
                Text("Notifications")
                    .font(.custom("Noto Sans", size: 28))
                    .fontWeight(.black)
                    .foregroundColor(Color.primaryGreen)
                
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
    
    // MARK: - Push Notifications Section
    var pushNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 0) {
                NotificationToggleRow(
                    title: "Push Notifications",
                    isOn: $settings.pushNotifications,
                    isEnabled: true
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
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
                    title: "Blood Pressure",
                    isOn: $settings.bloodPressure,
                    isEnabled: true
                )
                
                Divider().padding(.leading, 0)
                
                NotificationToggleRow(
                    title: "Blood Glucose",
                    isOn: $settings.bloodGlucose,
                    isEnabled: true
                )
                
                Divider().padding(.leading, 0)
                
                NotificationToggleRow(
                    title: "SpO2",
                    isOn: $settings.spo2,
                    isEnabled: true
                )
                
                Divider().padding(.leading, 0)
                
                NotificationToggleRow(
                    title: "Heart Rate",
                    isOn: $settings.heartRate,
                    isEnabled: true
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
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
                    title: "Medication Log",
                    isOn: $settings.medicationLog,
                    isEnabled: true
                )
                
                Divider().padding(.leading, 0)
                
                NotificationToggleRow(
                    title: "Weight",
                    isOn: $settings.weight,
                    isEnabled: true
                )
                
                Divider().padding(.leading, 0)
                
                NotificationToggleRow(
                    title: "Mood Tracker",
                    isOn: $settings.moodTracker,
                    isEnabled: true
                )
                
                Divider().padding(.leading, 0)
                
                NotificationToggleRow(
                    title: "Steps & Activity",
                    isOn: $settings.stepsAndActivity,
                    isEnabled: true
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
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
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(isEnabled ? Color.white : Color(red: 0.96, green: 0.96, blue: 0.96))
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
                        .shadow(color: Color.neutralShadow, radius: 2, x: 0, y: 1)
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

// MARK: - To preview Notifications page, for only developer uses
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
