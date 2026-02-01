// Onboarding page 1 out of 10 prompts user for their gender
import SwiftUI

struct SelectGenderView: View {
    let next: () -> Void
    let back: () -> Void
    let step: Int

    @StateObject private var dataManager = OnboardingDataManager.shared
    @State private var selectedGender: String? = nil
    let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
    
    // Map display names to API values
    private func mapGenderToAPI(_ displayName: String?) -> String? {
        guard let displayName = displayName else { return nil }
        switch displayName {
        case "Male": return "male"
        case "Female": return "female"
        case "Other": return "other"
        case "Prefer not to say": return "prefer_not_to_say"
        default: return nil
        }
    }

    var body: some View {
        OnboardingStepWrapper(step: step, title: "What is your gender?") {
            VStack(spacing: 16) {
                // Option buttons for user to select their gender
                ForEach(genderOptions, id: \.self) { gender in
                    Button(action: {
                        // Handles button selection and deselection
                        if selectedGender == gender {
                            // Lets the user deselect their selection
                            selectedGender = nil
                        } else {
                            selectedGender = gender
                        }
                    }) {
                        HStack {
                            Text(gender)
                                .foregroundColor(selectedGender == gender ? .white : Color(red: 0.18, green: 0.2, blue: 0.38))
                            Spacer()
                            ZStack {
                                Circle()
                                    .strokeBorder(Color.gray.opacity(0.4), lineWidth: 1)
                                    .background(
                                        Circle().fill(selectedGender == gender ? .white : Color.clear)
                                    )
                                    .frame(width: 20, height: 20)

                                if selectedGender == gender {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.primaryGreen)
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                        }
                        .padding()
                        .background(selectedGender == gender ? Color.secondaryGreen : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            
            Spacer()

            // Next button
            Button {
                if selectedGender != nil {
                    dataManager.gender = mapGenderToAPI(selectedGender)
                    next()
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(selectedGender != nil ? .white : .gray)
                    .background(selectedGender != nil ? Color.primaryGreen : .gray.opacity(0.3))
                    .cornerRadius(12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Load saved gender if any
            if let savedGender = dataManager.gender {
                switch savedGender {
                case "male": selectedGender = "Male"
                case "female": selectedGender = "Female"
                case "other": selectedGender = "Other"
                case "prefer_not_to_say": selectedGender = "Prefer not to say"
                default: break
                }
            }
        }
    }
}
