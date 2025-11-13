// Onboarding page 6 out of 9 prompts user for their current emotion (when they first signed up an account)
import SwiftUI

struct EmotionSelectionView: View {
    @State private var selectedEmotionIndex = 2

    let next: () -> Void
    let back: () -> Void
    let step: Int

    let emotions: [(iconName: String, description: String)] = [
        ("Emotion depressed", "exhausted"),
        ("Emotion sad", "a bit down"),
        ("Emotion neutral", "neutral"),
        ("Emotion happy", "content"),
        ("Emotion overjoyed", "happy")
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
                            Image(emotions[index].iconName)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(selectedEmotionIndex == index ? Color(red: 0.39, green: 0.59, blue: 0.38) : .gray)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: selectedEmotionIndex == index ? 56 : 48, 
                                       height: selectedEmotionIndex == index ? 56 : 48)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }

                // Description below icons
                Text("I’m feeling \(emotions[selectedEmotionIndex].description).")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))

                // Next button
                Button {
                    next()
                } label: {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.01, green: 0.33, blue: 0.18))
                        .cornerRadius(12)
                }

                Spacer()
            }
        }
    }
}
