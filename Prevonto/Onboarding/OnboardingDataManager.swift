// Onboarding Data Manager - Collects data from all 10 onboarding pages
import Foundation
import SwiftUI

class OnboardingDataManager: ObservableObject {
    static let shared = OnboardingDataManager()
    
    // Step 1: Gender
    @Published var gender: String? = nil
    
    // Step 2: Weight
    @Published var currentWeight: Double? = nil
    @Published var weightUnit: String? = nil // "kg" or "lbs"
    
    // Step 3: Age
    @Published var age: Int? = nil
    
    // Step 4: Fitness Level
    @Published var fitnessLevel: String? = nil
    
    // Step 5: Sleep Level
    @Published var sleepLevel: String? = nil
    
    // Step 6: Current Mood
    @Published var currentMood: String? = nil
    
    // Step 7: Diet
    @Published var dietType: String? = nil
    @Published var dietNotes: String? = nil
    
    // Step 8: Medications
    @Published var medications: [OnboardingMedicationEntry] = []
    
    // Step 9: Symptoms or Allergies
    @Published var symptomsOrAllergies: String? = nil
    
    // Step 10: Preferred Metrics
    @Published var preferredMetrics: [String] = []
    
    private init() {}
    
    // MARK: - Build Request
    func buildRequest() -> OnboardingRequest {
        return OnboardingRequest(
            gender: gender,
            currentWeight: currentWeight,
            weightUnit: weightUnit,
            age: age,
            fitnessLevel: fitnessLevel,
            sleepLevel: sleepLevel,
            currentMood: currentMood,
            dietType: dietType,
            dietNotes: dietNotes?.isEmpty == false ? dietNotes : nil,
            medications: medications.isEmpty ? nil : medications,
            symptomsOrAllergies: symptomsOrAllergies?.isEmpty == false ? symptomsOrAllergies : nil,
            preferredMetrics: preferredMetrics.isEmpty ? nil : preferredMetrics,
            isCompleted: false
        )
    }
    
    // MARK: - Reset
    func reset() {
        gender = nil
        currentWeight = nil
        weightUnit = nil
        age = nil
        fitnessLevel = nil
        sleepLevel = nil
        currentMood = nil
        dietType = nil
        dietNotes = nil
        medications = []
        symptomsOrAllergies = nil
        preferredMetrics = []
    }
}

