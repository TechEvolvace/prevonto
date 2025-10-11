// Settings page for the Prevonto app
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    @State private var navigateToSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Settings Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Section
                            profileSection
                            
                            // Personal Account Settings Section
                            personalAccountSection
                            
                            // Preferences & Controls Section
                            preferencesSection
                            
                            // Support & Resources Section
                            supportSection
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .alert("Are you sure you want to Log Out?", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                // Navigate to SignUpView
                navigateToSignUp = true
            }
        }
        .alert("Are you sure you want to Delete Your Account?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Account", role: .destructive) {
                // Navigate to SignUpView
                navigateToSignUp = true
            }
        } message: {
            Text("This action cannot be undone. All of your data will be permanently deleted.")
        }
        .navigationDestination(isPresented: $navigateToSignUp) {
            SignUpView()
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
                
                Text("Settings")
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
    
    // MARK: - Profile Section
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Name")
                    .font(.custom("Noto Sans", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                Spacer()
            }
            
            NavigationLink(destination: ProfileView()) {
                HStack {
                    // Profile Picture Placeholder
                    Circle()
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("My Profile")
                            .font(.custom("Noto Sans", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                        
                        Text("Set name")
                            .font(.custom("Noto Sans", size: 14))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Personal Account Settings Section
    var personalAccountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Account Settings")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            VStack(spacing: 0) {
                NavigationLink(destination: DevicesView()) {
                    SettingsRowView(
                        icon: "iphone",
                        title: "Devices",
                        subtitle: nil
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.leading, 44)
                
                NavigationLink(destination: LanguageView()) {
                    SettingsRowView(
                        icon: "globe",
                        title: "Languages",
                        subtitle: "English"
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Preferences & Controls Section
    var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences & Controls")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            VStack(spacing: 0) {
                NavigationLink(destination: NotificationsView()) {
                    SettingsRowView(
                        icon: "bell",
                        title: "Notifications",
                        subtitle: nil
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Support & Resources Section
    var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support & Resources")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            VStack(spacing: 0) {
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    SettingsRowView(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Logout",
                        subtitle: nil,
                        showChevron: false
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.leading, 44)
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    SettingsRowView(
                        icon: "trash",
                        title: "Delete Account",
                        subtitle: nil,
                        showChevron: false,
                        isDestructive: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRowView: View {
    let icon: String
    let title: String
    let subtitle: String?
    var showChevron: Bool = true
    var isDestructive: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isDestructive ? .red : Color(red: 0.60, green: 0.60, blue: 0.60))
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(isDestructive ? .red : Color(red: 0.404, green: 0.420, blue: 0.455))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                }
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
