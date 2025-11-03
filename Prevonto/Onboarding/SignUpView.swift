// This is the Sign Up page!
import SwiftUI

struct SignUpView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptedTerms = false
    @State private var navigateToGender = false

    @State private var showValidationMessage = false
    @State private var errorMessage = ""
    
    let testMode = true
    
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
        NavigationView {
            VStack(spacing: 16) {
                Spacer()

                Text("Let’s get Started")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
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

                // After signing up for an account, next page that shows up is controlled by OnboardingFlowView.swift file
                NavigationLink(destination: OnboardingFlowView(), isActive: $navigateToGender) {
                    EmptyView()
                }

                // Join button to check all entered credentials are valid before then proceed to the next page!
                // User clicks on the Join button after entering their credentials to successfully create their new acocunt!
                Button(action: {
                    if testMode {
                        navigateToGender = true
                    } else {
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
                            showValidationMessage = false
                            navigateToGender = true
                        }
                    }
                }) {
                    Text("Join")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.01, green: 0.33, blue: 0.18))
                        .cornerRadius(12)
                }


                HStack {
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    Text("Or")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                }

                HStack(spacing: 20) {
                    // Placeholder for extra buttons
                }

                Spacer()
            }
            .padding()
        }.navigationViewStyle(StackNavigationViewStyle())
            .preferredColorScheme(.light)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                .onTapGesture {
                    configuration.isOn.toggle()
                }

            configuration.label
        }
    }
}
