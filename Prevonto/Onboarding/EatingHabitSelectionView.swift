// Onboarding page 7 out of 9 prompts user for their current diet
import SwiftUI

struct EatingHabitSelectionView: View {
    @State private var selectedHabit: String? = nil

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
                        // Handles button selection and deselection
                        if selectedHabit == habit.label {
                            // Lets the user deselect their selection
                            selectedHabit = nil
                        } else {
                            selectedHabit = habit.label
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Image(habit.iconName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(selectedHabit == habit.label ? .white : Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.6))
                                    .frame(width: 26, height: 26)
                                    .aspectRatio(contentMode: .fit)
                                Text(habit.label)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedHabit == habit.label ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.white)
                        )
                        .foregroundColor(selectedHabit == habit.label ? .white : Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.6))
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
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(selectedHabit != nil ? .white : .gray)
                    .background(selectedHabit != nil ? Color(red: 0.01, green: 0.33, blue: 0.18) : .gray.opacity(0.3))
                    .cornerRadius(12)
            }
        }
    }
}
