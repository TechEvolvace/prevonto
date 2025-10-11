// Settings page for the Prevonto app
import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Settings Page")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
