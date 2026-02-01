// Metrics Data Seeder - Generates sample data for metrics
import Foundation

class MetricsDataSeeder {
    static let shared = MetricsDataSeeder()
    
    private let metricsService = MetricsService.shared
    private let onboardingService = OnboardingService.shared
    
    private init() {}
    
    // MARK: - Seed All Sample Data
    func seedSampleData() async throws {
        // Get onboarding completion date
        let onboarding = try await onboardingService.getOnboarding()
        guard let completedAt = onboarding.completedAt else {
            print("⚠️ Onboarding not completed yet, cannot seed data")
            return
        }
        
        let completionDate = completedAt
        
        // Seed only metrics that currently have NO logging UI in the app.
        // Weight, mood/energy, and blood pressure are logged via UI; medications are tracked via POST/DELETE on scheduled slots.
        
        // Seed steps data (last 7 days)
        try await seedStepsData(completionDate: completionDate)
        
        // Seed SpO2 data (last 3 days)
        try await seedSpO2Data(completionDate: completionDate)
        
        // Seed heart rate data (last 3 days)
        try await seedHeartRateData(completionDate: completionDate)
        
        // Seed blood glucose data (2 days prior)
        try await seedBloodGlucoseData(completionDate: completionDate)
        
        print("✅ Sample data seeding completed")
    }
    
    // MARK: - Seed Steps Data
    private func seedStepsData(completionDate: Date) async throws {
        let calendar = Calendar.current
        
        for dayOffset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: completionDate) else { continue }
            
            // Generate random steps between 5000 and 12000
            let steps = Int.random(in: 5000...12000)
            let distance = Double(steps) * 0.0008 // Approximate km (0.8m per step)
            let activeMinutes = Int.random(in: 20...60)
            
            let request = MetricCreateRequest.stepsActivity(
                steps: steps,
                distance: distance,
                activeMinutes: activeMinutes,
                measuredAt: date
            )
            _ = try await metricsService.createMetric(request)
        }
    }
    
    // MARK: - Seed SpO2 Data
    private func seedSpO2Data(completionDate: Date) async throws {
        let calendar = Calendar.current
        
        for dayOffset in -2...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: completionDate) else { continue }
            
            // Generate SpO2 between 95% and 99%
            let spo2 = Double.random(in: 95.0...99.0)
            
            let request = MetricCreateRequest.spo2(
                value: spo2,
                measuredAt: date,
                unit: "%"
            )
            _ = try await metricsService.createMetric(request)
        }
    }
    
    // MARK: - Seed Heart Rate Data
    private func seedHeartRateData(completionDate: Date) async throws {
        let calendar = Calendar.current
        
        // Day offset -2: 4 heart rate data samples at 10AM, 4PM, 6PM, and 9PM
        if let dayMinus2 = calendar.date(byAdding: .day, value: -2, to: completionDate) {
           let hours = [10, 16, 18, 21]
           for hour in hours {
               guard let measuredAt = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dayMinus2) else { continue }
               
               // Generate heart rate between 60 and 100 BPM
               let bpm = Int.random(in: 60...100)
               
                let request = MetricCreateRequest.heartRate(
                    bpm: bpm,
                    measuredAt: measuredAt,
                    unit: "bpm"
                )
                _ = try await metricsService.createMetric(request)
           }
        }
        
        // Generate 1 heart rate date sample for yesterday and today
        for dayOffset in -1...0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: completionDate) else { continue }
            
            // Generate heart rate between 80 and 100 BPM
            let bpm = Int.random(in: 80...100)
            
            let request = MetricCreateRequest.heartRate(
                bpm: bpm,
                measuredAt: date,
                unit: "bpm"
            )
            _ = try await metricsService.createMetric(request)
        }
    }
    
    // MARK: - Seed Blood Glucose Data
    private func seedBloodGlucoseData(completionDate: Date) async throws {
        let calendar = Calendar.current

        // Day offset -1: 4 blood glucose samples at 9AM, 12PM, 5PM, and 8PM
        if let dayMinus1 = calendar.date(byAdding: .day, value: -1, to: completionDate) {
            let hours = [9, 12, 17, 20]
            for hour in hours {
                guard let measuredAt = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dayMinus1) else { continue }
                let glucose = Double.random(in: 90.0...120.0)
                let request = MetricCreateRequest.bloodGlucose(
                    value: glucose,
                    measuredAt: measuredAt,
                    unit: "mg/dL"
                )
                _ = try await metricsService.createMetric(request)
            }
        }

        // Day offset -2: 2 blood glucose samples at 10AM and 2PM
        if let dayMinus2 = calendar.date(byAdding: .day, value: -2, to: completionDate) {
            let hours = [10, 14]
            for hour in hours {
                guard let measuredAt = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dayMinus2) else { continue }
                let glucose = Double.random(in: 90.0...120.0)
                let request = MetricCreateRequest.bloodGlucose(
                    value: glucose,
                    measuredAt: measuredAt,
                    unit: "mg/dL"
                )
                _ = try await metricsService.createMetric(request)
            }
        }
    }
}

