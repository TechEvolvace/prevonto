// This is the Sign Up page!
import SwiftUI

struct SignUpView: View {
    @Binding var showSignIn: Bool
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptedTerms = false
    @State private var navigateToGender = false

    @State private var showValidationMessage = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    @StateObject private var authManager = AuthManager.shared
    
    init(showSignIn: Binding<Bool> = .constant(false)) {
        _showSignIn = showSignIn
    }
    
    let testMode = false // Changed to false to use API
    
    // Supportive quotes to randomly display
    let healthQuotes = [
        "Prevention is better than care.",
        "Health is wealth.",
        "Take care of your body. It's the only place you have to live.",
        "Your health is an investment, not an expense.",
        "In health there is freedom. Health is the first of all liberties.",
        "The patient experience begins and ends with compassion.",
        "To truly imporve the patient experience, we must understand the patient journey from the patient's persepctive."
    ]

    var body: some View {
        VStack(spacing: 16) {
                Spacer()

                Text("Let’s get Started")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryGreen)
                    .padding(.bottom, 0)

                // Display a randomly chosen quote
                AnimatedQuoteView(quotes: healthQuotes)
                    .frame(height: 40)
                    .padding(.top, 0)
                    .padding(.bottom, 24)

                // A place for user to enter their credentials to create their new account
                // User enters their full name, email, and password to create their new account.
                // User also confirms their password too.
                Group {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .padding(.horizontal)
                .frame(height: 44)
                .background(Color.white)
                .overlay(Rectangle().frame(height: 1).padding(.top, 43), alignment: .top)
                .foregroundColor(.gray)

                // Checkbox that user must check to accept Prevonto's Privacy Policy and Term of Use before proceeding
                Toggle(isOn: $acceptedTerms) {
                    Text("By continuing you accept our Privacy Policy and Term of Use")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .toggleStyle(CheckboxToggleStyle())
                .padding(.top, 8)

                // Display Error Message for Invalid Credentials
                if showValidationMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }


                // User clicks on the Join button after entering their credentials to successfully create their new acocunt!
                Button(action: {
                    if testMode {
                        // For quicker testing by the developer
                        navigateToGender = true
                    } else {
                        // Check for valid credentials before user signs up for a new account
                        if fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                            errorMessage = "Please fill in all fields."
                            showValidationMessage = true
                        } else if password != confirmPassword {
                            errorMessage = "Passwords do not match."
                            showValidationMessage = true
                        } else if !acceptedTerms {
                            errorMessage = "Please accept the terms and conditions."
                            showValidationMessage = true
                        } else {
                            // Validate password complexity (matches API requirements)
                            if !isValidPassword(password) {
                                errorMessage = "Password must be at least 8 characters. Password must also include at least an uppercase letter, an lowercase letter, and a number."
                                showValidationMessage = true
                            } else {
                                showValidationMessage = false
                                registerUser()
                            }
                        }
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Join")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primaryGreen)
                    .cornerRadius(12)
                }
                .disabled(isLoading)


                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("Or")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }

                // Link to toggle to Sign In page
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Button(action: {
                        withAnimation {
                            showSignIn = true
                        }
                    }) {
                        Text("Sign In")
                            .foregroundColor(Color.primaryGreen)
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                }

                Spacer()
            }
            .padding()
            // After signing up for an account, next page that shows up is controlled by OnboardingFlowView.swift file
            .navigationDestination(isPresented: $navigateToGender) {
                OnboardingFlowView()
            }
    }
    
    // MARK: - Helper Functions
    private func isValidPassword(_ password: String) -> Bool {
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasUpperCase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowerCase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        return hasDigit && hasUpperCase && hasLowerCase && password.count >= 8
    }
    
    private func registerUser() {
        isLoading = true
        errorMessage = ""
        showValidationMessage = false
        
        Task {
            do {
                // Register user
                let _ = try await AuthService.shared.register(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    name: fullName.isEmpty ? nil : fullName.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                // Accept consent (HIPAA consent)
                try await AuthService.shared.acceptConsent(consentType: "hipaa_consent", version: "1.0")
                
                // Navigate to onboarding
                await MainActor.run {
                    isLoading = false
                    navigateToGender = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    if let apiError = error as? APIError {
                        errorMessage = apiError.errorDescription ?? "Registration failed"
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    showValidationMessage = true
                }
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.primaryGreen)
                .onTapGesture {
                    configuration.isOn.toggle()
                }

            configuration.label
        }
    }
}

// To preview the Sign Up page, for only developer uses
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView()
        }
    }
}
