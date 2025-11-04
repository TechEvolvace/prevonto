// Heart Rate page displays user's heart rate by day, week, or month.
import SwiftUI
import Charts

// Properties of Heart Rate data recorded from users
struct HeartRateRecord {
    let timestamp: Date
    let heartRate: Int
}

// Properties defined for Date
extension Date {
    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)!
    }
}

// Specify whether user selects "Day", "Week", or "Month" view mode
enum HeartRateChartMode: String, CaseIterable, Identifiable {
    case day, week, month
    var id: String { rawValue }
}

struct HeartRateView: View {
    // Default view mode selected is Day Mode
    @State private var selectedMode: HeartRateChartMode = .day
    // Specify what date the user selected
    @State private var selectedDate: Date = Date()
    // Help identify which bar from chart is selecting
    @State private var selectedBarIndex: Int? = nil
    
    // Sample Heart Rate data
    private let allHeartRateRecords: [HeartRateRecord] = [
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 7, day: 31, hour: 9, minute: 15), heartRate: 90),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 7, day: 31, hour: 3, minute: 45), heartRate: 99),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 1, hour: 12, minute: 5), heartRate: 88),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 1, hour: 14, minute: 12), heartRate: 75),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 2, hour: 16, minute: 24), heartRate: 75),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 3, hour: 16, minute: 24), heartRate: 82),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 4, hour: 16, minute: 24), heartRate: 76),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 5, hour: 16, minute: 03), heartRate: 80),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 7, hour: 16, minute: 14), heartRate: 67),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 16, minute: 22), heartRate: 75),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 8, minute: 40), heartRate: 76),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 9, minute: 10), heartRate: 68),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 9, minute: 30), heartRate: 72),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 10, minute: 35), heartRate: 70),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 10, minute: 50), heartRate: 72),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 11, minute: 10), heartRate: 70),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 11, minute: 30), heartRate: 65),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 11, minute: 45), heartRate: 66),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 12, minute: 5), heartRate: 68),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 13, minute: 15), heartRate: 80),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 14, minute: 34), heartRate: 74),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 15, minute: 26), heartRate: 72),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 8, hour: 16, minute: 7), heartRate: 75),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 8, minute: 40), heartRate: 76),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 9, minute: 10), heartRate: 80),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 9, minute: 30), heartRate: 82),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 10, minute: 35), heartRate: 84),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 10, minute: 50), heartRate: 85),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 11, minute: 10), heartRate: 82),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 11, minute: 30), heartRate: 83),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 11, minute: 45), heartRate: 84),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 12, minute: 5), heartRate: 76),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 13, minute: 15), heartRate: 77),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 14, minute: 34), heartRate: 75),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 15, minute: 26), heartRate: 78),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 9, hour: 16, minute: 7), heartRate: 79),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 9, minute: 13), heartRate: 76),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 9, minute: 15), heartRate: 83),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 10, minute: 24), heartRate: 85),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 12, minute: 10), heartRate: 90),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 12, minute: 25), heartRate: 92),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 12, minute: 40), heartRate: 94),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 13, minute: 10), heartRate: 88),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 13, minute: 23), heartRate: 86),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 13, minute: 44), heartRate: 84),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 14, minute: 24), heartRate: 77),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 14, minute: 40), heartRate: 70),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 14, minute: 50), heartRate: 66),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 15, minute: 05), heartRate: 70),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 15, minute: 28), heartRate: 76),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 15, minute: 40), heartRate: 72),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 16, minute: 10), heartRate: 74),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 16, minute: 35), heartRate: 75),
        HeartRateRecord(timestamp: Date.from(year: 2025, month: 8, day: 10, hour: 17, minute: 1), heartRate: 80),
    ]
    
    // Sample data gets processed into suitable chart data to be displayed in the Chart for current selected view mode.
    private var chartData: [(index: Int, label: String, min: Int?, max: Int?)] {
        aggregateHeartRate(for: allHeartRateRecords, mode: selectedMode, selectedDate: selectedDate)
            .enumerated()
            .map { (idx, item) in (index: idx, label: item.label, min: item.min, max: item.max) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Headline
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
                    
                    // View Mode Picker
                    HStack(spacing:20){
                        ForEach(HeartRateChartMode.allCases) { mode in
                            Button(action: {
                                selectedMode = mode
                            }){
                                Text(mode.rawValue.capitalized)
                                    .font(.headline)
                                    .foregroundStyle(selectedMode == mode ? .white : .primary)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 34)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedMode == mode ? Color.secondaryGreen : Color(.white))
                                    )
                                    .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 10)
                    .frame(width: 370)
                    
                    // Date Navigation
                    dateNavigationSection
                    
                    // Chart Area
                    VStack {

                        // Chart Title
                        Text("Beats Per Minute (BPM) over time")
                                .foregroundColor(.grayText)
                                .font(.headline)
                        
                        // Heart Rate Chart
                        Chart {
                            ForEach(chartData.indices, id: \.self) { idx in
                                let data = chartData[idx]
                                if let min = data.min, let max = data.max {
                                    BarMark(
                                        x: .value("Index", data.index),
                                        yStart: .value("Min", min),
                                        yEnd: .value("Max", max)
                                    )
                                    .foregroundStyle(.green.opacity(0.6))
                                    if min == max {
                                        PointMark(
                                            x: .value("Index", data.index),
                                            y: .value("Measurement", min)
                                        )
                                        .foregroundStyle(.green)
                                        .symbolSize(60)
                                    }
                                }
                            }
                        }
                        .frame(height: 300)
                        .chartXAxis {
                            AxisMarks(values: chartData.map { $0.index }) { value in
                                if let idx = value.as(Int.self), idx >= 0, idx < chartData.count && idx % 4 == 0 {
                                    AxisValueLabel {
                                        Text(chartData[idx].label).offset(x: -10)
                                    }
                                    AxisGridLine()
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Highlights Section
                    highlightsSection
                    
                    // Insights Section
                    insightsSection
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    // MARK: - Date Navigation Section
    var dateNavigationSection: some View {
        HStack {
            Button(action: {
                navigateDate(forward: false)
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
            
            Spacer()
            
            Text(dateRangeText)
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.grayText)
            
            Spacer()
            
            Button(action: {
                navigateDate(forward: true)
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
    }
    
    // MARK: - Highlights Section
    var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Highlights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            VStack(alignment: .leading, spacing: 12) {
                HighlightRow(number: 1, text: "Stable heart rate for 5 hours")
                HighlightRow(number: 2, text: "Rest periods usually fall between 12 am to 9 am")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
    }
    
    // MARK: - Insights Section
    var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            VStack(alignment: .leading, spacing: 12) {
                InsightRow(number: 1, text: "Try to complete one Breath Training every day")
                InsightRow(number: 2, text: "Don't smoke!")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 30)
    }
    
    // MARK: - Helper Functions
    private var dateRangeText: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        switch selectedMode {
        case .day:
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: selectedDate)
        case .week:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
                return ""
            }
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: weekInterval.start)
            let end = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: weekInterval.end)!)
            formatter.dateFormat = "yyyy"
            let year = formatter.string(from: selectedDate)
            return "\(start) - \(end), \(year)"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        }
    }
    
    private func navigateDate(forward: Bool) {
        let calendar = Calendar.current
        let component: Calendar.Component
        let value = forward ? 1 : -1
        
        switch selectedMode {
        case .day:
            component = .day
        case .week:
            component = .weekOfYear
        case .month:
            component = .month
        }
        
        if let newDate = calendar.date(byAdding: component, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// Colors used for the Heart Rate page
private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)
    static let grayText = Color(red: 0.25, green: 0.33, blue: 0.44)
}


// MARK: - Data Aggregation with complete axis
func aggregateHeartRate(for records: [HeartRateRecord],
                        mode: HeartRateChartMode,
                        selectedDate: Date) -> [(label: String, min: Int?, max: Int?)] {
    let calendar = Calendar.current
    let now = Date()
    let todayStart = calendar.startOfDay(for: now)
    
    switch mode {
    case .day:
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let filtered = records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay && $0.timestamp <= now }
        let grouped = groupByHour(records: filtered)
        
        // Debugging Day Mode
        for (hour, group) in grouped.sorted(by: { $0.key < $1.key }) {
            let hrValues = group.map(\.heartRate)
            print("Hour \(hour):", hrValues)
        }
        
        return (0..<24).map { hour in
            let label = String(format: "%02d:00", hour)
            // For current day, avoid future hours
            if calendar.isDate(selectedDate, inSameDayAs: now),
               hour > calendar.component(.hour, from: now) {
                return (label, nil as Int?, nil as Int?)
            }
            if let data = grouped[hour], !data.isEmpty {
                return (label, data.map(\.heartRate).min(), data.map(\.heartRate).max())
            } else {
                return (label, nil as Int?, nil as Int?)
            }
        }
        
    case .week:
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        let filtered = records.filter { weekInterval.contains($0.timestamp) && $0.timestamp <= now }
        let grouped = groupByWeekday(records: filtered)
        let weekdaySymbols = calendar.weekdaySymbols
        
        // Debug Week Mode
        for (weekday, group) in grouped.sorted(by: { $0.key < $1.key }) {
            let hrValues = group.map(\.heartRate)
            let name = weekdaySymbols[weekday - 1]
            print("\(name):", hrValues)
        }

        // Always show all 7 days
        // .date(bySetting: .weekday...) expects Sunday-based index (1...7)
        return (1...7).map { weekday in
            let label = weekdaySymbols[weekday - 1]
            
            // For current week, avoid future days
            if weekInterval.contains(todayStart),
                let dayDate = calendar.nextDate(after: weekInterval.start, matching: DateComponents(weekday: weekday), matchingPolicy: .nextTime, direction: .forward),
                dayDate > now {
                    return (label, nil as Int?, nil as Int?)
            }
            if let data = grouped[weekday], !data.isEmpty {
                return (label, data.map(\.heartRate).min(), data.map(\.heartRate).max())
            } else {
                return (label, nil as Int?, nil as Int?)
            }
        }
        
    case .month:
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let dayRange = calendar.range(of: .day, in: .month, for: selectedDate)
        else { return [] }

        let filtered = records.filter { monthInterval.contains($0.timestamp) && $0.timestamp <= now }
        let grouped = groupByDayOfMonth(records: filtered)
        
        for (day, group) in grouped.sorted(by: { $0.key < $1.key }) {
            let hrValues = group.map(\.heartRate)
            print("Day \(day):", hrValues)
        }

        return dayRange.map { day in
            let label = "\(day)"
            // For current month, avoid future days
            if calendar.isDate(selectedDate, equalTo: now, toGranularity: .month) &&
                day > calendar.component(.day, from: now) {
                return (label, nil as Int?, nil as Int?)
            }
            if let data = grouped[day], !data.isEmpty {
                return (label, data.map(\.heartRate).min(), data.map(\.heartRate).max())
            } else {
                return (label, nil as Int?, nil as Int?)
            }
        }
    }
}

// MARK: - Grouping
func groupByHour(records: [HeartRateRecord]) -> [Int: [HeartRateRecord]] {
    Dictionary(grouping: records) { Calendar.current.component(.hour, from: $0.timestamp) }
}
func groupByWeekday(records: [HeartRateRecord]) -> [Int: [HeartRateRecord]] {
    Dictionary(grouping: records) { Calendar.current.component(.weekday, from: $0.timestamp) }
}
func groupByDayOfMonth(records: [HeartRateRecord]) -> [Int: [HeartRateRecord]] {
    Dictionary(grouping: records) { Calendar.current.component(.day, from: $0.timestamp) }
}

// MARK: - Highlight Row Component
struct HighlightRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.38))
                .frame(width: 24, height: 24)
                .background(Color(red: 0.39, green: 0.59, blue: 0.38).opacity(0.15))
                .clipShape(Circle())
            
            Text(text)
                .font(.custom("Noto Sans", size: 16))
                .foregroundColor(Color(red: 0.25, green: 0.33, blue: 0.44))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// MARK: - Insight Row Component
struct InsightRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.38))
                .frame(width: 24, height: 24)
                .background(Color(red: 0.39, green: 0.59, blue: 0.38).opacity(0.15))
                .clipShape(Circle())
            
            Text(text)
                .font(.custom("Noto Sans", size: 16))
                .foregroundColor(Color(red: 0.25, green: 0.33, blue: 0.44))
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    HeartRateView()
}
