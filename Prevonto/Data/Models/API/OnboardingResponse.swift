// Onboarding Response Model
import Foundation

// Medication entry for response (that matches with API JSON structure)
struct OnboardingMedicationResponse: Codable {
    let name: String
    let dosage: String?
    let frequency: String?
}

// Onboarding data in response received from API
struct OnboardingResponse: Codable {
    let id: Int
    let userId: Int
    let gender: String?
    let currentWeight: Double?
    let weightUnit: String?
    let age: Int?
    let fitnessLevel: String?
    let sleepLevel: String?
    let currentMood: String?
    let dietType: String?
    let dietNotes: String?
    let medications: [OnboardingMedicationResponse]?
    let symptomsOrAllergies: String?
    let preferredMetrics: [String]?
    let isCompleted: Bool
    let completedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
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
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct OnboardingProgressResponse: Codable {
    let totalSteps: Int
    let completedSteps: Int
    let progressPercentage: Double
    let isCompleted: Bool
    let missingSteps: [String]
    let onboardingData: OnboardingResponse
    
    enum CodingKeys: String, CodingKey {
        case totalSteps = "total_steps"
        case completedSteps = "completed_steps"
        case progressPercentage = "progress_percentage"
        case isCompleted = "is_completed"
        case missingSteps = "missing_steps"
        case onboardingData = "onboarding_data"
    }
}

