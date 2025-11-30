// Onboarding Request Model
import Foundation

struct OnboardingMedicationEntry: Codable {
    let name: String
    let dosage: String?
    let frequency: String?
}

struct OnboardingRequest: Encodable {
    // Step 1: Gender
    var gender: String? // "male", "female", "other", "prefer_not_to_say"
    
    // Step 2: Weight
    var currentWeight: Double?
    var weightUnit: String? // "kg" or "lbs"
    
    // Step 3: Age
    var age: Int?
    
    // Step 4: Fitness Level
    var fitnessLevel: String? // "beginner", "intermediate", "advanced", "athlete"
    
    // Step 5: Sleep Level
    var sleepLevel: String? // "poor", "fair", "good", "excellent"
    
    // Step 6: Current Mood
    var currentMood: String? // "very_poor", "poor", "neutral", "good", "excellent"
    
    // Step 7: Diet
    var dietType: String? // "vegan", "vegetarian", "pescatarian", "omnivore", "keto", "paleo", "mediterranean", "other"
    var dietNotes: String?
    
    // Step 8: Medications
    var medications: [OnboardingMedicationEntry]?
    
    // Step 9: Symptoms or Allergies
    var symptomsOrAllergies: String?
    
    // Step 10: Preferred Metrics
    var preferredMetrics: [String]? // Ex: ["blood_pressure", "heart_rate", ...]
    
    // Completion
    var isCompleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case gender
        case currentWeight = "current_weight"
        case weightUnit = "weight_unit"
        case age
        case fitnessLevel = "fitness_level"
        case sleepLevel = "sleep_level"
        case currentMood = "current_mood"
        case dietType = "diet_type"
        case dietNotes = "diet_notes"
        case medications
        case symptomsOrAllergies = "symptoms_or_allergies"
        case preferredMetrics = "preferred_metrics"
        case isCompleted = "is_completed"
    }
}

