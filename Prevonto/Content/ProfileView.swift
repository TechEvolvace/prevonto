import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var dateOfBirth = Date()
    @State private var showingSaveAlert = false
    
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
                
                Text("My Profile")
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
    
    // MARK: - Profile Photo Section
    var profilePhotoSection: some View {
        VStack(spacing: 16) {
            Text("Your Name")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Profile Photo
                Circle()
                    .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    )
                
                Button(action: {
                    // Profile photo upload functionality placeholder
                }) {
                    Text("Change Photo")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
                // First Name
                ProfileInputField(
                    title: "First Name",
                    text: $firstName,
                    placeholder: "Enter your first name"
                )
                
                // Last Name
                ProfileInputField(
                    title: "Last Name",
                    text: $lastName,
                    placeholder: "Enter your last name"
                )
                
                // Email
                ProfileInputField(
                    title: "Email",
                    text: $email,
                    placeholder: "Enter your email address"
                )
                
                // Phone Number
                ProfileInputField(
                    title: "Phone Number",
                    text: $phoneNumber,
                    placeholder: "Enter your phone number"
                )
                
                // Date of Birth
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date of Birth")
                        .font(.custom("Noto Sans", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                    
                    DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Save Button
    var saveButton: some View {
        Button(action: {
            showingSaveAlert = true
        }) {
            Text("Save")
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
    }
}

// MARK: - Profile Input Field Component
struct ProfileInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Noto Sans", size: 14))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
            
            TextField(placeholder, text: $text)
                .font(.custom("Noto Sans", size: 16))
                .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
