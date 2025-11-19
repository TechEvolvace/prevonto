// Onboarding page 1 out of 9 prompts user for their gender
import SwiftUI

struct SelectGenderView: View {
    let next: () -> Void
    let back: () -> Void
    let step: Int

    @State private var selectedGender: String? = nil
    let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]

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
                                        .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                                        .font(.system(size: 10, weight: .bold))
                                }
                            }
                        }
                        .padding()
                        .background(selectedGender == gender ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.white)
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
                    next()
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(selectedGender != nil ? .white : .gray)
                    .background(selectedGender != nil ? Color(red: 0.01, green: 0.33, blue: 0.18) : .gray.opacity(0.3))
                    .cornerRadius(12)
            }
        }.navigationBarBackButtonHidden(true)
    }
}
