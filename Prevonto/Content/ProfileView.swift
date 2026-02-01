// Profile page for the user in Prevonto app
// User can change their full name, gender, and email here.
import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authManager = AuthManager.shared
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var showingSaveAlert = false
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedGender: Gender? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Profile Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Photo Section
                            profilePhotoSection
                            
                            // Basic Details Section
                            basicDetailsSection
                            
                            // Contact Details Section
                            contactDetailsSection
                            
                            // Save Button
                            saveButton
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .alert("Profile Saved", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text("Your profile information has been saved successfully.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    // MARK: - Load User Profile
    private func loadUserProfile() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                // Load user data
                let user = try await AuthService.shared.getCurrentUser()
                
                // Load onboarding data to get gender
                var onboardingGender: String? = nil
                do {
                    let onboarding = try await OnboardingService.shared.getOnboarding()
                    onboardingGender = onboarding.gender
                } catch {
                    // If onboarding data doesn't exist, that's okay - gender will be nil
                    print("Could not load onboarding data: \(error)")
                }
                
                await MainActor.run {
                    fullName = user.name ?? ""
                    email = user.email
                    
                    // Set gender from onboarding data (only if not "prefer_not_to_say")
                    if let genderString = onboardingGender?.lowercased(),
                       genderString != "prefer_not_to_say",
                       let gender = Gender(rawValue: genderString.capitalized) {
                        selectedGender = gender
                    } else {
                        selectedGender = nil // "Prefer Not to Say" or no selection
                    }
                    
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    // More detailed error handling
                    if let apiError = error as? APIError {
                        errorMessage = apiError.errorDescription ?? "Failed to load profile data"
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    print("Profile loading error: \(error)")
                    showError = true
                }
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
                
                Text("My Profile")
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
    
    // MARK: - Profile Photo Section
    var profilePhotoSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                // Profile Photo
                Circle()
                    .fill(Color(red: 0.86, green: 0.93, blue: 0.86))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    )
                
                // Photo upload into profile icon button here
                Button(action: {
                    // Profile photo upload functionality placeholder
                }) {
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    var basicDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Details")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            VStack(spacing: 20) {
                // Full Name
                ProfileInputField(
                    title: "Full Name",
                    text: $fullName,
                    placeholder: "Enter your full name"
                )
                
                // Gender Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .font(.custom("Noto Sans", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                    
                    HStack(spacing: 12) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            GenderButton(
                                gender: gender,
                                isSelected: selectedGender == gender,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        // Toggle: unselect if already selected, select if not
                                        selectedGender = selectedGender == gender ? nil : gender
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Contact Details Section
    var contactDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Details")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            VStack(spacing: 20) {
                // Email
                ProfileInputField(
                    title: "Email",
                    text: $email,
                    placeholder: "Enter your email address",
                    isEmail: true
                )
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Save Button
    var saveButton: some View {
        Button(action: {
            saveProfile()
        }) {
            HStack {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
            Text("Save")
                }
            }
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0.02, green: 0.33, blue: 0.18))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSaving)
    }
    
    // MARK: - Save Profile
    private func saveProfile() {
        isSaving = true
        errorMessage = ""
        
        Task {
            do {
                // Update user profile (name, email)
                let updatedUser = try await AuthService.shared.updateProfile(
                    name: fullName.isEmpty ? nil : fullName,
                    email: email.isEmpty ? nil : email
                )
                
                // Update onboarding gender (if changed)
                // Map selected gender to API format: nil if no selection, otherwise lowercase string
                let genderString = selectedGender == nil ? nil : selectedGender!.rawValue.lowercased()
                
                // Check if gender needs to be updated
                do {
                    let currentOnboarding = try await OnboardingService.shared.getOnboarding()
                    if currentOnboarding.gender?.lowercased() != genderString?.lowercased() {
                        // Gender changed, update it
                        var updateRequest = OnboardingRequest()
                        updateRequest.gender = genderString
                        _ = try await OnboardingService.shared.createOrUpdateOnboarding(updateRequest)
                    }
                } catch {
                    // If onboarding doesn't exist yet, create it with gender
                    var newOnboarding = OnboardingRequest()
                    newOnboarding.gender = genderString
                    _ = try await OnboardingService.shared.createOrUpdateOnboarding(newOnboarding)
                }
                
                await MainActor.run {
                    fullName = updatedUser.name ?? ""
                    email = updatedUser.email
                    
                    isSaving = false
                    showingSaveAlert = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    if let apiError = error as? APIError {
                        errorMessage = apiError.errorDescription ?? "Failed to save profile"
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    showError = true
                }
            }
        }
    }
}

// MARK: - Profile Input Field Component
struct ProfileInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isEmail: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Noto Sans", size: 14))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
            
            TextField(placeholder, text: $text)
                .font(.custom("Noto Sans", size: 16))
                .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                .keyboardType(isEmail ? .emailAddress : .default)
                .autocapitalization(isEmail ? .none : .sentences)
                .autocorrectionDisabled(isEmail)
                .textContentType(isEmail ? .emailAddress : nil)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                )
        }
    }
}

// MARK: - Gender Button Component
struct GenderButton: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(gender.rawValue)
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Color(red: 0.404, green: 0.420, blue: 0.455))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? Color.secondaryGreen : Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.clear : Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Gender Enum
enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

// MARK: - To preview Profile page, for only developer uses
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
