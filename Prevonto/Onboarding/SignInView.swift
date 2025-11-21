// This is the Sign In page!
import SwiftUI

struct SignInView: View {
    @Binding var showSignIn: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToDashboard = false

    @State private var showValidationMessage = false
    @State private var errorMessage = ""
    
    init(showSignIn: Binding<Bool> = .constant(true)) {
        _showSignIn = showSignIn
    }
    
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
        VStack(spacing: 16) {
                Spacer()

                Text("Welcome Back")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                    .padding(.bottom, 0)

                // Display a randomly chosen quote
                AnimatedQuoteView(quotes: healthQuotes)
                    .frame(height: 40)
                    .padding(.top, 0)
                    .padding(.bottom, 24)

                // A place for user to enter their credentials to sign in to their account
                // User enters their email and password to sign in to their account.
                Group {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                .padding(.horizontal)
                .frame(height: 44)
                .background(Color.white)
                .overlay(Rectangle().frame(height: 1).padding(.top, 43), alignment: .top)
                .foregroundColor(.gray)

                // Display Error Message for Invalid Credentials
                if showValidationMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }


                // Join button users click on after entering their credentials to successfully create their new acocunt!
                Button(action: {
                    if testMode {
                        // For quicker testing by the developer
                        navigateToDashboard = true
                    } else {
                        // Check for valid credentials before user signs in
                        if email.isEmpty || password.isEmpty {
                            errorMessage = "Please fill in all fields."
                            showValidationMessage = true
                        } else {
                            showValidationMessage = false
                            navigateToDashboard = true
                        }
                    }
                }) {
                    Text("Sign In")
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

                // Link to toggle to Sign Up page
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Button(action: {
                        withAnimation {
                            showSignIn = false
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                }

                Spacer()
            }
            .padding()
            // After signing in, user goes directly to the Dashboard page (ContentView) as a full screen cover
            .fullScreenCover(isPresented: $navigateToDashboard) {
                ContentView()
            }
    }
}

// To preview the Sign In page, for only developer uses
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignInView()
        }
    }
}

