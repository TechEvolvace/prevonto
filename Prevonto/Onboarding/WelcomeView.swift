// This is the app's landing page, the Welcome page!
import SwiftUI

struct WelcomeView: View {
    @State private var showAppIntro = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Prevonto title
            Text("Prevonto")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(Color.primaryGreen)
            
            // Prevonto app slogan
            Text("Let’s Take Control...")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Color.darkGrayText)
                
            Spacer()
                
            // Let's Go button to go to the App Intro pages!
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAppIntro = true
                }
            }) {
                Text("Let's Go")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primaryGreen)
                    .cornerRadius(16)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showAppIntro) {
            AppIntroView()
                .transition(.move(edge: .bottom))
        }
    }
}

// Developers can see a preview of Prevonto's Welcome page.
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
