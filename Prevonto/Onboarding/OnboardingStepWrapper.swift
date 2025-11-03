// Component for displaying the horizontal progress tracker and subtext below for the 9 onboarding pages for Prevonto app
// shown to the user after signing up for an account
import SwiftUI

struct OnboardingStepWrapper<Content: View>: View {
    let step: Int
    let totalSteps: Int
    let title: String
    let content: Content

    init(step: Int, totalSteps: Int = 9, title: String, @ViewBuilder content: () -> Content) {
        self.step = step
        self.totalSteps = totalSteps
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 30) {
            // Step indicator and progress bar
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: Double(step + 1), total: Double(totalSteps))
                    .accentColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                Text("\(step + 1) of \(totalSteps)")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }

            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                .frame(maxWidth: .infinity, alignment: .leading)

            content

            Spacer()
        }
        .padding()
    }
}
