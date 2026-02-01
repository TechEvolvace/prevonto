// API-based weight repository
import Foundation

class APIWeightRepository: WeightRepository {
    private let metricsService = MetricsService.shared
    private var entries: [WeightEntry] = []
    
    init() {
        // Load will be called explicitly
    }
    
    func fetchEntries() -> [WeightEntry] {
        return entries
    }
    
    func addEntry(weight: Double) {
        // This will be async, but we'll handle it in the manager
        // Do nothing here - manager calls addEntryAsync directly
    }
    
    func addEntryAsync(weight: Double) async throws {
        // Convert lbs to kg for API
        let weightKg = weight * 0.453592
        
        // Get weight unit preference (default to kg)
        let weightUnit = UserDefaults.standard.string(forKey: "weightUnit") ?? "kg"
        let unit = weightUnit == "lbs" ? "lbs" : "kg"
        
        let request = MetricCreateRequest.weight(
            weight: weightKg,
            measuredAt: Date(),
            unit: unit
        )
        
        let response = try await metricsService.createMetric(request)
        
        if let weightValue = response.extractWeight() {
            let weightLb = weightValue.weight * 2.20462
            let newEntry = WeightEntry(date: response.measuredAt, weightLb: weightLb)
            entries.insert(newEntry, at: 0)
        }
    }

    // Load existing weight metrics from API
    func loadEntries() async throws {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -3, to: endDate) ?? endDate

        let response = try await metricsService.listMetrics(
            metricType: .weight,
            startDate: startDate,
            endDate: endDate,
            pageSize: 100
        )

        // Convert API metrics to WeightEntry
        entries = response.metrics.compactMap { metric -> WeightEntry? in
            guard let weightValue = metric.extractWeight() else { return nil }
            // API stores weight in kg, convert to lbs for WeightEntry
            let weightLb = weightValue.weight * 2.20462
            return WeightEntry(date: metric.measuredAt, weightLb: weightLb)
        }

        // Sort by date descending
        entries.sort { $0.date > $1.date }
    }
}

