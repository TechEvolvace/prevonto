// Controlling the Navigation through the 9 onboarding pages after user signs up for an account
import SwiftUI

struct OnboardingFlowView: View {
    @State private var step = 0

    var body: some View {
        VStack {
            switch step {
            case 0:
                // 1st onboarding page prompts user for their gender
                SelectGenderView(next: { step = 1 }, back: { step = 0 }, step: step)
            case 1:
                // 2nd onboarding page prompts user for their weight
                WeightSelectionView(next: { step = 2 }, back: { step = 0 }, step: step)
            case 2:
                // 3rd onboarding page prompts user for their age
                AgeSelectionView(next: { step = 3 }, back: { step = 1 }, step: step)
            case 3:
                // 4th onboarding page prompts user for their level of fitness
                FitnessLevelSelectionView(next: { step = 4 }, back: { step = 2 }, step: step)
            case 4:
                // 5th onboarding page prompts user for their level amount of sleep
                SleepLevelSelectionView(next: { step = 5 }, back: { step = 3 }, step: step)
            case 5:
                // 6th onboarding page prompts user for their current mood (right when they sign up for an account)
                EmotionSelectionView(next: { step = 6 }, back: { step = 4 }, step: step)
            case 6:
                // 7th onboarding page prompts user for their eating diet
                EatingHabitSelectionView(next: { step = 7 }, back: { step = 5 }, step: step)
            case 7:
                // 8th onboarding page prompts user for any and all medications they take
                MedicationSelectionView(next: { step = 8 }, back: { step = 6 }, step: step)
            case 8:
                // 9th onboarding page prompts user for any and all allergies they have
                SymptomsAllergyInputView(next: { step = 9 }, back: { step = 7 }, step: step)
                
            case 9:
                // 10th onboarding page prompts user for any metrics they want to see on the Dashboard
                MetricsSelectionView(next: { step = 10 }, back: { step = 8 }, step: step)

            default:
                // After the user goes through the 9 onbaoarding page, they will arrive at the Dashboard page, which is primarily handled by ContentView.swift file.
                ContentView()
            }
        }
        // Back button navigation
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if step > 0 && step < 10 {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        step -= 1
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

struct OnboardingFlowContainerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingFlowView()
        }
    }
}
