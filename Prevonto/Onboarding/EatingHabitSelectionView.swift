// Onboarding page 7 out of 10 prompts user for their current diet
import SwiftUI

struct EatingHabitSelectionView: View {
    @StateObject private var dataManager = OnboardingDataManager.shared
    @State private var selectedHabit: String? = nil

    let next: () -> Void
    let back: () -> Void
    let step: Int

    struct HabitOption: Identifiable {
        let id = UUID()
        let iconName: String
        let label: String
        let apiValue: String // API enum value
    }

    // Available eating habit options user can select in this page mapped to appropriate API values
    let habits: [HabitOption] = [
        .init(iconName: "Balanced Diet icon", label: "Balanced Diet", apiValue: "omnivore"),
        .init(iconName: "Mostly Vegetarian icon", label: "Mostly Vegetarian", apiValue: "vegetarian"),
        .init(iconName: "Low Carb icon", label: "Low Carb", apiValue: "keto"),
        .init(iconName: "Gluten Free icon", label: "Gluten Free", apiValue: "other"),
        .init(iconName: "Vegan icon", label: "Vegan", apiValue: "vegan"),
        .init(iconName: "Keto icon", label: "Keto", apiValue: "keto")
    ]
    
    private func mapDietTypeToAPI(_ label: String?) -> String? {
        guard let label = label else { return nil }
        return habits.first(where: { $0.label == label })?.apiValue
    }
    
    private func mapAPIToDietType(_ apiValue: String?) -> String? {
        guard let apiValue = apiValue else { return nil }
        return habits.first(where: { $0.apiValue == apiValue })?.label
    }

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
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedHabit == habit.label ? Color.secondaryGreen : Color.white)
                        )
                        .foregroundColor(selectedHabit == habit.label ? .white : Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.6))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
            }

            Spacer()

            Button {
                if selectedHabit != nil {
                    dataManager.dietType = mapDietTypeToAPI(selectedHabit)
                    next()
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(selectedHabit != nil ? .white : .gray)
                    .background(selectedHabit != nil ? Color.primaryGreen : .gray.opacity(0.3))
                    .cornerRadius(12)
            }
        }
        .onAppear {
            // Load saved diet type if any
            if let savedDietType = dataManager.dietType {
                selectedHabit = mapAPIToDietType(savedDietType)
            }
        }
    }
}
