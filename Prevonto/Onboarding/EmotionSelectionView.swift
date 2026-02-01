// Onboarding page 6 out of 10 prompts user for their current emotion (when they first signed up an account)
import SwiftUI

struct EmotionSelectionView: View {
    @StateObject private var dataManager = OnboardingDataManager.shared
    @State private var selectedEmotionIndex = 2

    let next: () -> Void
    let back: () -> Void
    let step: Int

    // Available emotion options user can select in this page mapped to appropriate API values
    let emotions: [(iconName: String, description: String, apiValue: String)] = [
        ("Emotion depressed", "depressed", "very_poor"),
        ("Emotion sad", "sad", "poor"),
        ("Emotion neutral", "neutral", "neutral"),
        ("Emotion happy", "happy", "good"),
        ("Emotion overjoyed", "overjoyed", "excellent")
    ]

    var body: some View {
        OnboardingStepWrapper(step: step, title: "How do you feel\nright now?") {
            VStack(spacing: 24) {
                // Emotion icons
                HStack(spacing: 16) {
                    ForEach(emotions.indices, id: \.self) { index in
                        Button(action: {
                            selectedEmotionIndex = index
                        }) {
                            let isNeutral = index == 2 // Emotion neutral
                            let baseIconSize: CGFloat = selectedEmotionIndex == index ? 80 : 60
                            
                            Image(emotions[index].iconName)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(selectedEmotionIndex == index ? Color.secondaryGreen : .gray)
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(isNeutral ? 2.6 : 1.0, anchor: .center)
                                .frame(width: baseIconSize, height: baseIconSize)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // Description below icons
                Text("I’m feeling \(emotions[selectedEmotionIndex].description).")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Spacer()

                // Next button
                Button {
                    dataManager.currentMood = emotions[selectedEmotionIndex].apiValue
                    next()
                } label: {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryGreen)
                        .cornerRadius(12)
                }
            }
        }
        .onAppear {
            // Load saved mood if any
            if let savedMood = dataManager.currentMood {
                if let index = emotions.firstIndex(where: { $0.apiValue == savedMood }) {
                    selectedEmotionIndex = index
                }
            }
        }
    }
}
