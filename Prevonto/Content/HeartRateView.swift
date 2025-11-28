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
    // Week mode start and end date pickers
    @State private var showingStartDatePicker: Bool = false
    @State private var showingEndDatePicker: Bool = false
    @State private var weekStartDate: Date = Date()
    @State private var weekEndDate: Date = Date()
    
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
        aggregateHeartRate(
            for: allHeartRateRecords,
            mode: selectedMode,
            selectedDate: selectedDate,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate
        )
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
                    .onTapGesture {
                        unselectChartData()
                    }
                    
                    // Average Heart Rate Card
                    averageHeartRateCard
                        .onTapGesture {
                            unselectChartData()
                        }
                    
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
                    chartSection
                    
                    // Highlights Section
                    highlightsSection
                        .onTapGesture {
                            unselectChartData()
                        }
                    
                    // Insights Section
                    insightsSection
                        .onTapGesture {
                            unselectChartData()
                        }
                }
                .padding(.horizontal, 15)
            }
        }
        .onAppear {
            updateWeekDates()
        }
    }
    
    // MARK: - Average Heart Rate Card
    var averageHeartRateCard: some View {
        VStack(spacing: 8) {
            Text("\(averageHeartRate)")
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.primaryGreen)
            + Text(" bpm")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(.primaryGreen)
            
            Text(averageLabel)
                .font(.custom("Noto Sans", size: 16))
                .foregroundColor(.grayText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 16)
    }
    
    private var averageHeartRate: Int {
        let dataWithValues = chartData.filter { $0.min != nil && $0.max != nil }
        guard !dataWithValues.isEmpty else { return 0 }
        
        let sum = dataWithValues.reduce(0) { total, data in
            let avg = (data.min! + data.max!) / 2
            return total + avg
        }
        return sum / dataWithValues.count
    }
    
    private var averageLabel: String {
        switch selectedMode {
        case .day:
            return "Daily Average"
        case .week:
            return "Weekly Average"
        case .month:
            return "Monthly Average"
        }
    }
    
    // MARK: - Chart Section
    var chartSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Beats Per Minute (BPM) over time")
                .foregroundColor(.grayText)
                .font(.system(size: 18, weight: .semibold))
            
            heartRateChart
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 20)
        .onChange(of: selectedMode) { _, _ in
            // Dismiss popover when switching modes
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedBarIndex = nil
            }
        }
    }
    
    // MARK: - Heart Rate Chart
    var heartRateChart: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dynamically adjust height of empty space for popover to appear without overlapping any text
            Spacer()
                .frame(height: selectedBarIndex != nil ? 60 : 15)
                .animation(.easeInOut(duration: 0.3), value: selectedBarIndex)
            
            Chart {
                ForEach(chartData.indices, id: \.self) { idx in
                    let data = chartData[idx]
                    let isSelected = selectedBarIndex == idx
                    
                    if let min = data.min, let max = data.max {
                        if min == max {
                            // Point mark for single values (when minimum and maximum values are the same)
                            if selectedMode == .day {
                                PointMark(
                                    x: .value("Index", data.index),
                                    y: .value("Measurement", min)
                                )
                                .foregroundStyle(isSelected ? Color.secondaryGreen : Color.barDefault)
                                .symbolSize(60)
                            } else {
                                PointMark(
                                    x: .value("Label", data.label),
                                    y: .value("Measurement", min)
                                )
                                .foregroundStyle(isSelected ? Color.secondaryGreen : Color.barDefault)
                                .symbolSize(60)
                            }
                        } else {
                            // Bar mark extending from min to max
                            if selectedMode == .day {
                                BarMark(
                                    x: .value("Index", data.index),
                                    yStart: .value("Min", min),
                                    yEnd: .value("Max", max)
                                )
                                .foregroundStyle(isSelected ? Color.secondaryGreen : Color.barDefault)
                                .cornerRadius(4)
                            } else {
                                BarMark(
                                    x: .value("Label", data.label),
                                    yStart: .value("Min", min),
                                    yEnd: .value("Max", max)
                                )
                                .foregroundStyle(isSelected ? Color.secondaryGreen : Color.barDefault)
                                .cornerRadius(4)
                            }
                        }
                        
                        // Vertical rule line for selected data
                        if isSelected {
                            if selectedMode == .day {
                                RuleMark(x: .value("Index", data.index))
                                    .foregroundStyle(Color.secondaryGreen)
                                    .lineStyle(StrokeStyle(lineWidth: 2))
                                    .annotation(position: .top, alignment: .center, spacing: 0) {
                                        selectionTooltip(for: data, min: min, max: max)
                                    }
                            } else {
                                RuleMark(x: .value("Label", data.label))
                                    .foregroundStyle(Color.secondaryGreen)
                                    .lineStyle(StrokeStyle(lineWidth: 2))
                                    .annotation(position: .top, alignment: .center, spacing: 0) {
                                        selectionTooltip(for: data, min: min, max: max)
                                    }
                            }
                        }
                    } else {
                        // When there's no data
                        if selectedMode == .day {
                            BarMark(
                                x: .value("Index", data.index),
                                yStart: .value("Min", 0),
                                yEnd: .value("Max", 0)
                            )
                            .foregroundStyle(.clear)
                        } else {
                            BarMark(
                                x: .value("Label", data.label),
                                yStart: .value("Min", 0),
                                yEnd: .value("Max", 0)
                            )
                            .foregroundStyle(.clear)
                        }
                    }
                }
            }
            .frame(height: 260) // Extra height to accommodate popover
            .chartXAxis {
                if selectedMode == .day {
                    AxisMarks(values: [0, 3, 6, 9, 12, 15, 18, 21]) { value in
                        if let hour = value.as(Int.self) {
                            AxisValueLabel(horizontalSpacing: -5, verticalSpacing: 16) {
                                Text(hourLabel(for: hour))
                                    .font(.system(size: 11))
                            }
                            AxisTick(length: 12)
                            AxisGridLine()
                        }
                    }
                } else if selectedMode == .month {
                    // For month mode, only show labels at days 1, 7, 14, 21, 28
                    AxisMarks { value in
                        AxisGridLine()
                        if let label = value.as(String.self) {
                            let labelsToShow = ["1", "7", "14", "21", "28"]
                            if labelsToShow.contains(label) {
                                AxisValueLabel(verticalSpacing: 12)
                                    .font(.system(size: xAxisFontSize))
                            }
                        }
                    }
                } else {
                    // For week mode, show all labels
                    AxisMarks { value in
                        AxisValueLabel(verticalSpacing: 12)
                            .font(.system(size: xAxisFontSize))
                        AxisGridLine()
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisValueLabel(horizontalSpacing: 16)
                }
            }
            .chartYScale(domain: 0...200)
            .modifier(DayModeXScaleModifier(isDayMode: selectedMode == .day))
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            handleChartTap(at: location, proxy: proxy, geometry: geometry)
                        }
                }
            }
        }
    }
    
    private var xAxisFontSize: CGFloat {
        switch selectedMode {
        case .week:
            return 13
        case .month:
            return 12
        default:
            return 12
        }
    }
    
    // Selection tooltip view
    private func selectionTooltip(for data: (index: Int, label: String, min: Int?, max: Int?), min: Int, max: Int) -> some View {
        VStack(spacing: 2) {
            Text(tooltipTimeLabel(for: data))
                .font(.system(size: 12, weight: .semibold))
            Text("min: \(min) | max: \(max)")
                .font(.system(size: 11))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.selectionGreen)
        .cornerRadius(6)
    }
    
    // Format tooltip label based on mode
    private func tooltipTimeLabel(for data: (index: Int, label: String, min: Int?, max: Int?)) -> String {
        switch selectedMode {
        case .day:
            // Show hour (e.g., "12 pm")
            let hour = data.index
            if hour == 0 {
                return "12 am"
            } else if hour < 12 {
                return "\(hour) am"
            } else if hour == 12 {
                return "12 pm"
            } else {
                return "\(hour - 12) pm"
            }
        case .week:
            // Show day of week (abbreviated)
            return data.label
        case .month:
            // Format as abbreviated month, day, year
            let calendar = Calendar.current
            if let date = calendar.date(bySetting: .day, value: data.index + 1, of: selectedDate) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: date)
            }
            return data.label
        }
    }
    
    // Handle tap on chart using precise plotFrame calculation
    private func handleChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let plotArea = geometry[plotFrame]
        
        // Check if tap is within the plot area
        let relativeX = location.x - plotArea.origin.x
        
        guard relativeX >= 0 && relativeX <= plotArea.width else {
            // Animate spacer height change when dismissing popover by tapping outside chart
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedBarIndex = nil
            }
            return
        }
        
        // Calculate which bar was tapped based on position
        let dataCount = CGFloat(chartData.count)
        guard dataCount > 0 else { return }
        
        let barWidth = plotArea.width / dataCount
        let tappedIndex = Int(relativeX / barWidth)
        
        guard tappedIndex >= 0 && tappedIndex < chartData.count else {
            // Animate spacer height change when dismissing popover for invalid tap index
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedBarIndex = nil
            }
            return
        }
        
        // Check if this data point has data
        let data = chartData[tappedIndex]
        if data.min == nil || data.max == nil {
            // If tapping on a bar with no data, just deselect any current selection
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedBarIndex = nil
            }
            return
        }
        
        // Animate spacer height change when showing/dismissing popover on bar tap
        withAnimation(.easeInOut(duration: 0.3)) {
            if selectedBarIndex == tappedIndex {
                selectedBarIndex = nil
            } else {
                selectedBarIndex = tappedIndex
            }
        }
    }
    
    // Unselect when tapping outside the chart
    private func unselectChartData() {
        selectedBarIndex = nil
    }
    
    
    // Format hour label for day mode
    private func hourLabel(for hour: Int) -> String {
        if hour == 0 { return "12a" }
        else if hour < 12 { return "\(hour)a" }
        else if hour == 12 { return "12p" }
        else { return "\(hour - 12)p" }
    }
    
    // MARK: - Chart Components
    @AxisContentBuilder
    private var chartXAxisMarks: some AxisContent {
        AxisMarks(values: chartData.map { $0.index }) { value in
            if let idx = value.as(Int.self), idx >= 0, idx < chartData.count {
                let shouldShow = shouldShowAxisLabel(at: idx)
                
                if shouldShow {
                    AxisValueLabel(verticalSpacing: 16){
                        Text(chartData[idx].label)
                            .font(.system(size: selectedMode == .week ? 11 : 12))
                    }
                    AxisTick(length: 12)
                    AxisGridLine()
                }
            }
        }
    }
    
    private func shouldShowAxisLabel(at index: Int) -> Bool {
        switch selectedMode {
        case .day:
            return index % 4 == 0
        case .week:
            return true // Show all 7 days
        case .month:
            return index % 4 == 0
        }
    }
    
    // MARK: - Date Navigation Section
    var dateNavigationSection: some View {
        VStack(spacing: 12) {
            // Month navigation buttons, looks like (< May 2025 >)
            monthNavigationButtons
            
            // Mode-specific date selectors
            switch selectedMode {
            case .day:
                daySelector
                    .padding(.bottom, 16)
            case .week:
                weekSelector
                    .padding(.bottom, 16)
            case .month:
                EmptyView()
            }
        }
    }
    
    private var monthNavigationButtons: some View {
        HStack {
            Button(action: {
                navigateMonth(forward: false)
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
            
            Spacer()
            
            Text(monthYearText)
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.grayText)
            
            Spacer()
            
            Button(action: {
                navigateMonth(forward: true)
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
    }
    
    // MARK: - Day Selector
    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(daysInCurrentMonth, id: \.self) { date in
                    dayButton(for: date)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func dayButton(for date: Date) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        // Use 3-letter abbreviated day names (Mon, Tue, etc.)
        let weekdaySymbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
        
        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 4) {
                Text(weekdaySymbol)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .grayText)
                
                Text("\(day)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primaryGreen)
            }
            .frame(width: 50, height: 60)
            .background(isSelected ? Color.secondaryGreen : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var daysInCurrentMonth: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let dayRange = calendar.range(of: .day, in: .month, for: selectedDate) else {
            return []
        }
        
        return dayRange.compactMap { day in
            calendar.date(bySetting: .day, value: day, of: monthInterval.start)
        }
    }
    
    // MARK: - Week Selector
    private var weekSelector: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                weekDateButton(
                    title: "start date",
                    date: weekStartDate,
                    isShowing: showingStartDatePicker,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showingStartDatePicker.toggle()
                            if showingStartDatePicker {
                                showingEndDatePicker = false
                            }
                        }
                    }
                )
                
                Text("to")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(.grayText)
                
                weekDateButton(
                    title: "end date",
                    date: weekEndDate,
                    isShowing: showingEndDatePicker,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showingEndDatePicker.toggle()
                            if showingEndDatePicker {
                                showingStartDatePicker = false
                            }
                        }
                    }
                )
            }
            .padding(.horizontal, 16)
            
            if showingStartDatePicker {
                weekDatePickerView(for: $weekStartDate)
                    .background(
                        Color.black.opacity(0.001)
                            .onTapGesture {
                                dismissStartDatePicker()
                            }
                    )
            }
            
            if showingEndDatePicker {
                weekDatePickerView(for: $weekEndDate)
                    .background(
                        Color.black.opacity(0.001)
                            .onTapGesture {
                                dismissEndDatePicker()
                            }
                    )
            }
        }
    }
    
    private func dismissStartDatePicker() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            // Update end date to be 6 days after start date
            let calendar = Calendar.current
            if let newEndDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate) {
                weekEndDate = newEndDate
            }
            showingStartDatePicker = false
            updateSelectedDateFromWeek()
        }
    }
    
    private func dismissEndDatePicker() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            // Update start date to be 6 days before end date
            let calendar = Calendar.current
            if let newStartDate = calendar.date(byAdding: .day, value: -6, to: weekEndDate) {
                weekStartDate = newStartDate
            }
            showingEndDatePicker = false
            updateSelectedDateFromWeek()
        }
    }
    
    private func weekDateButton(title: String, date: Date, isShowing: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundColor(.grayText)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11))
                        .foregroundColor(.grayText)
                    Text(weekDateFormatter.string(from: date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func weekDatePickerView(for binding: Binding<Date>) -> some View {
        let isStartDate = binding.wrappedValue == weekStartDate
        
        return DatePicker(
            "",
            selection: binding,
            displayedComponents: .date
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
        .onChange(of: binding.wrappedValue) { _, newDate in
            // Update opposite date in real-time while calendar is open
            let calendar = Calendar.current
            if isStartDate {
                // Update end date to be 6 days after start date
                if let newEndDate = calendar.date(byAdding: .day, value: 6, to: newDate) {
                    weekEndDate = newEndDate
                }
            } else {
                // Update start date to be 6 days before end date
                if let newStartDate = calendar.date(byAdding: .day, value: -6, to: newDate) {
                    weekStartDate = newStartDate
                }
            }
            updateSelectedDateFromWeek()
        }
    }
    
    // MARK: - Highlights Section
    var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Highlights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            if hasHighlightsData {
                VStack(alignment: .leading, spacing: 0) {
                    HighlightRow(number: 1, text: "Stable heart rate for 5 hours", isLast: false)
                    HighlightRow(number: 2, text: "Rest periods usually fall between 12 am to 9 am", isLast: true)
                }
            } else {
                Text("No data available to generate highlights")
                    .font(.custom("Noto Sans", size: 16))
                    .foregroundColor(.grayText)
                    .padding(.vertical, 12)
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
            
            if hasInsightsData {
                VStack(alignment: .leading, spacing: 0) {
                    InsightRow(number: 1, text: "Try to complete one Breath Training every day", isLast: false)
                    InsightRow(number: 2, text: "Don't smoke!", isLast: true)
                }
            } else {
                Text("No data available to generate insights")
                    .font(.custom("Noto Sans", size: 16))
                    .foregroundColor(.grayText)
                    .padding(.vertical, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 30)
    }
    
    private var hasHighlightsData: Bool {
        // Check if there's any actual heart rate data in the selected period
        return chartData.contains { $0.min != nil && $0.max != nil }
    }
    
    private var hasInsightsData: Bool {
        // Check if there's any actual heart rate data in the selected period
        return chartData.contains { $0.min != nil && $0.max != nil }
    }
    
    // MARK: - Helper Functions
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var weekDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    private func navigateMonth(forward: Bool) {
        let calendar = Calendar.current
        let value = forward ? 1 : -1
        
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
            
            // Update week dates if in week mode
            if selectedMode == .week {
                updateWeekDates()
            }
        }
    }
    
    private func updateWeekDates() {
        let calendar = Calendar.current
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) {
            weekStartDate = weekInterval.start
            weekEndDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
        }
    }
    
    private func updateSelectedDateFromWeek() {
        // Update selectedDate to be within the selected week range
        selectedDate = weekStartDate
    }
}

// Colors used for the Heart Rate page
private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)
    static let grayText = Color(red: 0.25, green: 0.33, blue: 0.44)
    static let barDefault = Color(red: 0.682, green: 0.698, blue: 0.788)
    
    // #608E61 for selection highlight
    static let selectionGreen = Color(red: 96/255, green: 142/255, blue: 97/255)
}


// MARK: - View Modifier for Day Mode X-Scale
struct DayModeXScaleModifier: ViewModifier {
    let isDayMode: Bool
    
    func body(content: Content) -> some View {
        if isDayMode {
            content.chartXScale(domain: 0...23)
        } else {
            content
        }
    }
}

// MARK: - Data Aggregation with complete axis
func aggregateHeartRate(for records: [HeartRateRecord],
                        mode: HeartRateChartMode,
                        selectedDate: Date,
                        weekStartDate: Date,
                        weekEndDate: Date) -> [(label: String, min: Int?, max: Int?)] {
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
        // Use the selected week start and end dates
        let startOfWeek = calendar.startOfDay(for: weekStartDate)
        let endOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: weekEndDate)!)
        
        // Filter records within the selected week range
        let filtered = records.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek && $0.timestamp <= now }
        
        // Group by actual date (not weekday)
        let groupedByDate = Dictionary(grouping: filtered) { record -> Date in
            calendar.startOfDay(for: record.timestamp)
        }
        
        // Generate 7 days starting from weekStartDate
        return (0..<7).map { dayOffset in
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
                return ("", nil as Int?, nil as Int?)
            }
            
            // Get short weekday name for the actual date
            let weekdayIndex = calendar.component(.weekday, from: currentDate) - 1
            let label = calendar.shortWeekdaySymbols[weekdayIndex]
            
            // Don't show future days
            if currentDate > now {
                return (label, nil as Int?, nil as Int?)
            }
            
            // Get data for this specific date
            if let data = groupedByDate[currentDate], !data.isEmpty {
                let heartRates = data.map(\.heartRate)
                return (label, heartRates.min(), heartRates.max())
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
    let isLast: Bool
    
    // #F0F1F9 converted to RGB (240/255, 241/255, 249/255)
    private let bulletBackgroundColor = Color(red: 240/255, green: 241/255, blue: 249/255)
    // Same color as "Heart Rate" title
    private let numberColor = Color(red: 0.01, green: 0.33, blue: 0.18)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // Numbered circle bullet point
                Text("\(number)")
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(numberColor)
                    .frame(width: 32, height: 32)
                    .background(bulletBackgroundColor)
                    .clipShape(Circle())
                
                // Highlight text
                Text(text)
                    .font(.custom("Noto Sans", size: 16))
                    .foregroundColor(Color(red: 0.25, green: 0.33, blue: 0.44))
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            if !isLast {
                Divider()
                    .frame(height: 1)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
            }
        }
    }
}

// MARK: - Insight Row Component
struct InsightRow: View {
    let number: Int
    let text: String
    let isLast: Bool
    
    // #F0F1F9 converted to RGB (240/255, 241/255, 249/255)
    private let bulletBackgroundColor = Color(red: 240/255, green: 241/255, blue: 249/255)
    // Same color as "Heart Rate" title
    private let numberColor = Color(red: 0.01, green: 0.33, blue: 0.18)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                // Numbered circle bullet point
                Text("\(number)")
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(numberColor)
                    .frame(width: 32, height: 32)
                    .background(bulletBackgroundColor)
                    .clipShape(Circle())
                
                // Insight text
                Text(text)
                    .font(.custom("Noto Sans", size: 16))
                    .foregroundColor(Color(red: 0.25, green: 0.33, blue: 0.44))
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            if !isLast {
                Divider()
                    .frame(height: 1)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
            }
        }
    }
}

#Preview {
    HeartRateView()
}
