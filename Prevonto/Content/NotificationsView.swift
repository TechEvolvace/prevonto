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
                    Text("Notifications Page")
                }
                .navigationBarHidden(true)
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
