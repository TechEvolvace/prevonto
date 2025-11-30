// Settings page for the Prevonto app
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showLogoutSheet = false
    @State private var showDeleteSheet = false
    @State private var navigateToSignUp = false
    @State private var isLoggingOut = false
    @State private var isDeletingAccount = false
    @StateObject private var authManager = AuthManager.shared
    
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
        // Logout Confirmation Sheet
        .sheet(isPresented: $showLogoutSheet) {
            VStack(spacing: 24) {
                // Logout Warning Message Messages
                VStack(spacing: 8) {
                    Text("Are you sure you want to Log out?")
                        .font(.custom("Noto Sans", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Text("Your data will be saved.")
                        .font(.custom("Noto Sans", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455).opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(spacing: 12) {
                    // Cancel button in Log out modal sheet
                    Button("Cancel") {
                        showLogoutSheet = false
                    }
                    .font(.custom("Noto Sans", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    // Log out button in Log out modal sheet
                    Button(action: {
                        logout()
                    }) {
                        HStack {
                            if isLoggingOut {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log Out")
                            }
                        }
                        .font(.custom("Noto Sans", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.13, green: 0.54, blue: 0.24))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .disabled(isLoggingOut)
                }
            }
            .presentationDetents([.height(250)])
            .background(Color.white)
            .cornerRadius(24)
        }
        // Delete Account Confirmation Sheet
        .sheet(isPresented: $showDeleteSheet) {
            VStack(spacing: 20) {
                // Delete Account Warning Messages
                VStack(spacing: 8) {
                    Text("Are you sure you want to Delete Your Account?")
                        .font(.custom("Noto Sans", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Text("This will delete all your existing data.")
                        .font(.custom("Noto Sans", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455).opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(spacing: 12) {
                    // Cancel button in Delete Account modal sheet
                    Button("Cancel") {
                        showDeleteSheet = false
                    }
                    .font(.custom("Noto Sans", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    // Delete Account button in Delete Account modal sheet
                    Button(action: {
                        deleteAccount()
                    }) {
                        HStack {
                            if isDeletingAccount {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Delete Account")
                            }
                        }
                        .font(.custom("Noto Sans", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    .disabled(isDeletingAccount)
                }
            }
            .presentationDetents([.height(250)])
            .background(Color.white)
            .cornerRadius(18)
        }
        // Navigate to AuthView (which manages SignUp/SignIn toggle) without back button
        .fullScreenCover(isPresented: $navigateToSignUp) {
            AuthView()
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
                
                Text("Settings")
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
    
    // MARK: - Profile Section
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            NavigationLink(destination: ProfileView()) {
                HStack {
                    // Profile Picture Placeholder
                    Circle()
                        .fill(Color(red: 0.86, green: 0.93, blue: 0.86))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                        )
                        .padding(.trailing, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Name")
                            .font(.custom("Noto Sans", size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                        
                        Text("yourname@example.com")
                            .font(.custom("Noto Sans", size: 14))
                            .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
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
                        subtitle: nil,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 6,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 6
                    )
                )
                
                NavigationLink(destination: LanguageView()) {
                    SettingsRowView(
                        icon: "globe",
                        title: "Language",
                        subtitle: "English"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showLogoutSheet = true
                }) {
                    SettingsRowView(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Logout",
                        subtitle: nil,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showDeleteSheet = true
                }) {
                    SettingsRowView(
                        icon: "trash",
                        title: "Delete Account",
                        subtitle: nil,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 6,
                        bottomTrailingRadius: 6,
                        topTrailingRadius: 6
                    )
                )
            }
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
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
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
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
                    // Insert Help functionality here
                }) {
                    SettingsRowView(
                        icon: "questionmark.circle",
                        title: "Help",
                        subtitle: nil,
                        showChevron: true
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Functions
    private func logout() {
        isLoggingOut = true
        
        Task {
            do {
                try await AuthService.shared.logout()
                await MainActor.run {
                    isLoggingOut = false
                    showLogoutSheet = false
                    navigateToSignUp = true
                }
            } catch {
                // Even if logout fails on server, clear local tokens
                await MainActor.run {
                    AuthManager.shared.clearTokens()
                    isLoggingOut = false
                    showLogoutSheet = false
                    navigateToSignUp = true
                }
            }
        }
    }
    
    private func deleteAccount() {
        isDeletingAccount = true
        
        Task {
            do {
                try await SettingsService.shared.deleteAccount(password: nil)
                await MainActor.run {
                    isDeletingAccount = false
                    showDeleteSheet = false
                    navigateToSignUp = true
                }
            } catch {
                await MainActor.run {
                    isDeletingAccount = false
                    // Show error - for now just close sheet
                    // TODO: Show error alert
                    showDeleteSheet = false
                }
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
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                
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
                    .fontWeight(.medium)
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
