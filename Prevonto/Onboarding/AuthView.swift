// AuthView manages the toggle between Sign Up and Sign In pages.
import SwiftUI

struct AuthView: View {
    @State private var showSignIn = false
    
    var body: some View {
        NavigationView {
            Group {
                if showSignIn {
                    SignInView(showSignIn: $showSignIn)
                        .id("SignIn")
                } else {
                    SignUpView(showSignIn: $showSignIn)
                        .id("SignUp")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
    }
}
