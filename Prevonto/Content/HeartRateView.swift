import SwiftUI
import Charts

struct HeartRateRecord {
    let timestamp: Date
    let heartRate: Int
}

enum HeartRateChartMode: String, CaseIterable, Identifiable {
    case day, week, month
    var id: String { rawValue }
}

struct HeartRateView: View {
    @State private var selectedMode: HeartRateChartMode = .day
    @State private var selectedDate: Date = Date()
    
    // Sample data
    private let allHeartRateRecords: [HeartRateRecord] = generateSampleData()
    
    private var chartData: [(label: String, min: Int, max: Int)] {
        aggregateHeartRate(for: allHeartRateRecords, mode: selectedMode, selectedDate: selectedDate)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Heart Page Headline
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Heart Rate")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                        
                        Text("Your heart rate is monitored through your watch when in sync with the app.")
                            .font(.subheadline)
                            .foregroundColor(.grayText)
                    }
                    .padding(.vertical, 15)
                    
                    // Mode Picker
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(HeartRateChartMode.allCases) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 10)
                    
                    // === Chart Placement Below Heading ===
                    VStack {
                        Chart {
                            ForEach(chartData.indices, id: \.self) { idx in
                                let data = chartData[idx]
                                BarMark(
                                    x: .value("Time", data.label),
                                    yStart: .value("Min", data.min),
                                    yEnd: .value("Max", data.max)
                                )
                                .foregroundStyle(.green.opacity(0.6))
                            }
                        }
                        .frame(height: 300)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let grayText = Color(red: 0.25, green: 0.33, blue: 0.44)
}

// MARK: - Data Aggregation
func aggregateHeartRate(for records: [HeartRateRecord],
                        mode: HeartRateChartMode,
                        selectedDate: Date) -> [(label: String, min: Int, max: Int)] {
    switch mode {
    case .day:
        let filtered = filterForSelectedDay(records, selectedDate: selectedDate)
        let grouped = groupByHour(records: filtered)
        return grouped.sorted(by: { $0.key < $1.key }).map { key, records in
            (String(format: "%02d:00", key),
             records.map(\.heartRate).min() ?? 0,
             records.map(\.heartRate).max() ?? 0)
        }
    case .week:
        let filtered = filterForSelectedWeek(records, selectedDate: selectedDate)
        let grouped = groupByWeekday(records: filtered)
        let weekdaySymbols = Calendar.current.weekdaySymbols
        return grouped.sorted(by: { $0.key < $1.key }).map { key, records in
            (weekdaySymbols[key - 1],
             records.map(\.heartRate).min() ?? 0,
             records.map(\.heartRate).max() ?? 0)
        }
    case .month:
        let filtered = filterForSelectedMonth(records, selectedDate: selectedDate)
        let grouped = groupByDayOfMonth(records: filtered)
        return grouped.sorted(by: { $0.key < $1.key }).map { key, records in
            ("\((key))",
             records.map(\.heartRate).min() ?? 0,
             records.map(\.heartRate).max() ?? 0)
        }
    }
}

// MARK: - Filtering Helpers
func filterForSelectedDay(_ records: [HeartRateRecord], selectedDate: Date) -> [HeartRateRecord] {
    let start = Calendar.current.startOfDay(for: selectedDate)
    let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
    return records.filter { $0.timestamp >= start && $0.timestamp < end }
}
func filterForSelectedWeek(_ records: [HeartRateRecord], selectedDate: Date) -> [HeartRateRecord] {
    guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
    return records.filter { interval.contains($0.timestamp) }
}
func filterForSelectedMonth(_ records: [HeartRateRecord], selectedDate: Date) -> [HeartRateRecord] {
    guard let interval = Calendar.current.dateInterval(of: .month, for: selectedDate) else { return [] }
    return records.filter { interval.contains($0.timestamp) }
}

// MARK: - Grouping Helpers
func groupByHour(records: [HeartRateRecord]) -> [Int: [HeartRateRecord]] {
    Dictionary(grouping: records) { Calendar.current.component(.hour, from: $0.timestamp) }
}
func groupByWeekday(records: [HeartRateRecord]) -> [Int: [HeartRateRecord]] {
    Dictionary(grouping: records) { Calendar.current.component(.weekday, from: $0.timestamp) }
}
func groupByDayOfMonth(records: [HeartRateRecord]) -> [Int: [HeartRateRecord]] {
    Dictionary(grouping: records) { Calendar.current.component(.day, from: $0.timestamp) }
}

// MARK: - Sample Data Generator
func generateSampleData() -> [HeartRateRecord] {
    var data: [HeartRateRecord] = []
    let now = Date()
    let calendar = Calendar.current
    
    // Create 3 days worth of random HR data
    for dayOffset in -2...0 {
        if let date = calendar.date(byAdding: .day, value: dayOffset, to: now) {
            for hour in 0..<24 {
                let sampleCount = Int.random(in: 1...4) // multiple readings per hour
                for _ in 0..<sampleCount {
                    if let timestamp = calendar.date(bySettingHour: hour, minute: Int.random(in: 0..<60), second: 0, of: date) {
                        let hr = Int.random(in: 60...120)
                        data.append(HeartRateRecord(timestamp: timestamp, heartRate: hr))
                    }
                }
            }
        }
    }
    return data
}

#Preview {
    HeartRateView()
}
