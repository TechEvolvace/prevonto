import SwiftUI

struct FitnessLevelSelectionView: View {
    @State private var selectedLevel: Int? = nil

    let next: () -> Void
    let back: () -> Void
    let step: Int

    struct FitnessOption: Identifiable {
        let id: Int
        let title: String
        let subtitle: String?
    }

    let fitnessOptions: [FitnessOption] = [
        .init(id: 1, title: "Just started", subtitle: nil),
        .init(id: 2, title: "Getting back into fitness", subtitle: nil),
        .init(id: 3, title: "Fairly active", subtitle: nil),
        .init(id: 4, title: "Very active", subtitle: nil)
    ]

    var body: some View {
        OnboardingStepWrapper(step: step, title: "What is your current\nfitness level?") {
            VStack(spacing: 20) {
                ForEach(fitnessOptions) { option in
                    Button(action: {
                        selectedLevel = option.id
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .fontWeight(.semibold)
                                if let subtitle = option.subtitle {
                                    Text(subtitle)
                                        .font(.caption)
                                }
                            }

                            Spacer()

                            ZStack {
                                Circle()
                                    .strokeBorder(Color.gray.opacity(0.4), lineWidth: 1)
                                    .background(
                                        Circle().fill(selectedLevel == option.id ? .white : Color.clear)
                                    )
                                    .frame(width: 20, height: 20)

                                if selectedLevel == option.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                        }
                        .padding()
                        .background(
                            selectedLevel == option.id ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.white
                        )
                        .foregroundColor(selectedLevel == option.id ? .white : .black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }

                Spacer()

                Button {
                    if selectedLevel != nil {
                        next()
                    }
                } label: {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.01, green: 0.33, blue: 0.18))
                        .cornerRadius(12)
                }
            }
        }
    }
}
