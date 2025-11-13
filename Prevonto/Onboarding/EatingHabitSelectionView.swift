// Onboarding page 7 out of 9 prompts user for their current diet
import SwiftUI

struct EatingHabitSelectionView: View {
    @State private var selectedHabit: String? = "Mostly Vegetarian"

    let next: () -> Void
    let back: () -> Void
    let step: Int

    struct HabitOption: Identifiable {
        let id = UUID()
        let iconName: String
        let label: String
    }

    let habits: [HabitOption] = [
        .init(iconName: "Balanced Diet icon", label: "Balanced Diet"),
        .init(iconName: "Mostly Vegetarian icon", label: "Mostly Vegetarian"),
        .init(iconName: "Low Carb icon", label: "Low Carb"),
        .init(iconName: "Gluten Free icon", label: "Gluten Free"),
        .init(iconName: "Vegan icon", label: "Vegan"),
        .init(iconName: "Keto icon", label: "Keto")
    ]

    var body: some View {
        OnboardingStepWrapper(step: step, title: "What does your current\ndiet look like?") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(habits) { habit in
                    Button(action: {
                        selectedHabit = habit.label
                    }) {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(spacing: 4) {
                                Image(habit.iconName)
                                    .resizable()
                                    .renderingMode(selectedHabit == habit.label ? .template : .original)
                                    .foregroundColor(selectedHabit == habit.label ? .white : nil)
                                    .frame(width: 26, height: 26)
                                    .aspectRatio(contentMode: .fit)
                                Text(habit.label)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                            }

                            Spacer()

                            if selectedHabit == habit.label {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedHabit == habit.label ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.white)
                        )
                        .foregroundColor(selectedHabit == habit.label ? .white : .black)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
            }

            Spacer()

            Button {
                if selectedHabit != nil {
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
