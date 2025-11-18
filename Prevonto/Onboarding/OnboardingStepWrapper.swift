// Component for displaying the horizontal progress tracker and subtext below for the 9 onboarding pages for Prevonto app
// shown to the user after signing up for an account
import SwiftUI

struct OnboardingStepWrapper<Content: View>: View {
    let step: Int
    let totalSteps: Int
    let title: String
    let content: Content
    
    private let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    private let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)

    init(step: Int, totalSteps: Int = 9, title: String, @ViewBuilder content: () -> Content) {
        self.step = step
        self.totalSteps = totalSteps
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 30) {
            // Segmented progress bar
            VStack(alignment: .leading, spacing: 8) {
                SegmentedProgressBar(
                    currentStep: step + 1,
                    totalSteps: totalSteps,
                    activeColor: primaryGreen,
                    inactiveColor: Color.gray.opacity(0.3)
                )
                
                Text("\(step + 1) of \(totalSteps)")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }

            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(primaryGreen)
                .frame(maxWidth: .infinity, alignment: .leading)

            content

            Spacer()
        }
        .padding()
    }
}

// MARK: - Segmented Progress Bar
struct SegmentedProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    let activeColor: Color
    let inactiveColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? activeColor : inactiveColor)
                    .frame(height: 4)
            }
        }
    }
}
