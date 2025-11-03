// Prevonto App starts with the Welcome page displayed,
// which the Welcome page is handled by WelcomeView.swift file.
import SwiftUI

@main
struct PrevontoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WelcomeView()
            }
        }
    }
}
