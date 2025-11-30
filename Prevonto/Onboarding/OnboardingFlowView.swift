// Controlling the Navigation through the 10 onboarding pages after user signs up for an account
import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var dataManager = OnboardingDataManager.shared
    @State private var step = 0
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToDashboard = false

    var body: some View {
        VStack {
            if isLoading {
                // Loading view while submitting data
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Saving your information...")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
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
                    MetricsSelectionView(next: { submitOnboarding() }, back: { step = 8 }, step: step)

                default:
                    // After the user goes through all 10 onboarding pages, they will arrive at the Dashboard page
                    DashboardView()
                }
            }
        }
        // Back button navigation
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if step > 0 && step < 10 && !isLoading {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        step -= 1
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .fullScreenCover(isPresented: $navigateToDashboard) {
            DashboardView()
        }
    }
    
    // MARK: - Submit Onboarding Data
    private func submitOnboarding() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Build onboarding request from collected data
                var request = dataManager.buildRequest()
                request.isCompleted = true
                
                // Submit all onboarding data to API
                let onboardingResponse = try await OnboardingService.shared.createOrUpdateOnboarding(request)
                
                // Mark onboarding as completed (separate call)
                let completedResponse = try await OnboardingService.shared.completeOnboarding()
                
                // Initialize notification settings from preferred metrics
                await MainActor.run {
                    initializeNotificationSettings(from: completedResponse.preferredMetrics ?? onboardingResponse.preferredMetrics ?? [])
                    dataManager.reset()
                    isLoading = false
                    navigateToDashboard = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    // Extract more detailed error message
                    if let apiError = error as? APIError {
                        errorMessage = apiError.errorDescription ?? "Failed to save onboarding data"
                    } else {
                        let nsError = error as NSError
                        errorMessage = nsError.localizedDescription
                        print("Onboarding submission error: \(nsError)")
                        print("Error domain: \(nsError.domain), code: \(nsError.code)")
                        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                            print("Underlying error: \(underlyingError)")
                        }
                    }
                    showError = true
                }
            }
        }
    }
    
    // MARK: - Initialize Notification Settings
    private func initializeNotificationSettings(from preferredMetrics: [String]) {
        // Map API metric types to notification setting keys
        // Default: all metrics are OFF, then turn ON only the preferred ones
        UserDefaults.standard.set(false, forKey: "showBloodPressure")
        UserDefaults.standard.set(false, forKey: "showBloodGlucose")
        UserDefaults.standard.set(false, forKey: "showSpO2")
        UserDefaults.standard.set(false, forKey: "showHeartRate")
        UserDefaults.standard.set(false, forKey: "showWeight")
        UserDefaults.standard.set(false, forKey: "showStepsActivity")
        UserDefaults.standard.set(false, forKey: "showMoodTracker")
        UserDefaults.standard.set(false, forKey: "showMedicationLog")
        
        // Map API metric type strings to UserDefaults keys
        // API uses: blood_pressure, heart_rate, blood_glucose, spo2, weight, steps_activity, energy_mood, medication
        let metricToKeyMap: [String: String] = [
            "blood_pressure": "showBloodPressure",
            "blood_glucose": "showBloodGlucose",
            "spo2": "showSpO2",
            "heart_rate": "showHeartRate",
            "weight": "showWeight",
            "steps_activity": "showStepsActivity",
            "energy_mood": "showMoodTracker",
            "medication": "showMedicationLog"
        ]
        
        // Set preferred metrics to true
        for metric in preferredMetrics {
            if let key = metricToKeyMap[metric.lowercased()] {
                UserDefaults.standard.set(true, forKey: key)
            }
        }
    }
}

struct OnboardingFlowContainerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingFlowView()
        }
    }
}
