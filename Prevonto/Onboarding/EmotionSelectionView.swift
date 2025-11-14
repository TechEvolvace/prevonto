// Onboarding page 6 out of 9 prompts user for their current emotion (when they first signed up an account)
import SwiftUI

struct EmotionSelectionView: View {
    @State private var selectedEmotionIndex = 2

    let next: () -> Void
    let back: () -> Void
    let step: Int

    let emotions: [(iconName: String, description: String)] = [
        ("Emotion depressed", "depressed"),
        ("Emotion sad", "sad"),
        ("Emotion neutral", "neutral"),
        ("Emotion happy", "happy"),
        ("Emotion overjoyed", "overjoyed")
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
                            let baseIconSize: CGFloat = selectedEmotionIndex == index ? 88 : 60
                            
                            Image(emotions[index].iconName)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(selectedEmotionIndex == index ? Color(red: 0.39, green: 0.59, blue: 0.38) : .gray)
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(isNeutral ? 2.6 : 1.0, anchor: .center)
                                .frame(width: baseIconSize, height: baseIconSize)
                                .background(Color.clear)
                                .contentShape(RoundedRectangle(cornerRadius: 12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(PlainButtonStyle())
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
