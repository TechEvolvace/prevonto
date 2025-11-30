// Onboarding page 5 out of 10 prompts user for their level amount of sleep
import SwiftUI

struct SleepLevelSelectionView: View {
    @StateObject private var dataManager = OnboardingDataManager.shared
    @State private var selectedLevel: Int? = nil
    
    let next: () -> Void
    let back: () -> Void
    let step: Int

    struct SleepOption: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let apiValue: String // API enum value
    }

    // Available sleep level options user can select in this page mapped to appropriate API values
    let sleepOptions: [SleepOption] = [
        .init(id: 1, title: "Very Low", subtitle: "~0–3 hours daily", apiValue: "poor"),
        .init(id: 2, title: "Low", subtitle: "~3–5 hours daily", apiValue: "poor"),
        .init(id: 3, title: "Moderate", subtitle: "~5–8 hours daily", apiValue: "fair"),
        .init(id: 4, title: "High", subtitle: "~8–10 hours daily", apiValue: "good"),
        .init(id: 5, title: "Excellent", subtitle: "10+ hours daily", apiValue: "excellent")
    ]
    
    private func mapSleepLevelToAPI(_ levelId: Int?) -> String? {
        guard let levelId = levelId else { return nil }
        return sleepOptions.first(where: { $0.id == levelId })?.apiValue
    }
    
    private func mapAPIToSleepLevel(_ apiValue: String?) -> Int? {
        guard let apiValue = apiValue else { return nil }
        return sleepOptions.first(where: { $0.apiValue == apiValue })?.id
    }

    var body: some View {
        OnboardingStepWrapper(step: step, title: "What is your current\nsleep level?") {
            VStack(spacing: 20) {
                ForEach(sleepOptions) { option in
                    Button(action: {
                        // Handles button selection and deselection
                        if selectedLevel == option.id {
                            // Lets the user deselect their selection
                            selectedLevel = nil
                        } else {
                            selectedLevel = option.id
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.title)
                                    .fontWeight(.semibold)
                                Text(option.subtitle)
                                    .font(.caption)
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
                                        .foregroundColor(Color.primaryGreen)
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                        }
                        .padding()
                        .background(selectedLevel == option.id ? Color.secondaryGreen : Color.white)
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
                        dataManager.sleepLevel = mapSleepLevelToAPI(selectedLevel)
                        next()
                    }
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(selectedLevel != nil ? .white : .gray)
                        .background(selectedLevel != nil ? Color.primaryGreen : .gray.opacity(0.3))
                        .cornerRadius(12)
                }
            }
        }
        .onAppear {
            // Load saved sleep level if any
            if let savedLevel = dataManager.sleepLevel {
                selectedLevel = mapAPIToSleepLevel(savedLevel)
            }
        }
    }
}
