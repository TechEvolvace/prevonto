import SwiftUI

struct OnboardingFlowView: View {
    @State private var step = 0

    var body: some View {
        VStack {
            switch step {
            case 0:
                SelectGenderView(next: { step = 1 }, back: { step = 0 }, step: step)
            case 1:
                WeightSelectionView(next: { step = 2 }, back: { step = 0 }, step: step)
            case 2:
                AgeSelectionView(next: { step = 3 }, back: { step = 1 }, step: step)
            case 3:
                FitnessLevelSelectionView(next: { step = 4 }, back: { step = 2 }, step: step)
            case 4:
                SleepLevelSelectionView(next: { step = 5 }, back: { step = 3 }, step: step)
            case 5:
                EmotionSelectionView(next: { step = 6 }, back: { step = 4 }, step: step)
            case 6:
                EatingHabitSelectionView(next: { step = 7 }, back: { step = 5 }, step: step)
            case 7:
                MedicationSelectionView(next: { step = 8 }, back: { step = 6 }, step: step)
            case 8:
                SymptomsAllergyInputView(next: { step = 9 }, back: { step = 7 }, step: step)

            default:
                ContentView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if step > 0 && step < 9 {
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
