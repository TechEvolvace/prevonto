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
                ForEach(genderOptions, id: \.self) { gender in
                    Button(action: {
                        selectedGender = gender
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

            Button {
                if selectedGender != nil {
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
