// This is the Steps and Activity Page, which shows the user's calories burned, minutes moving, hours standing, and numbers of steps taken.
import SwiftUI
import Charts

// Properties of Steps data recorded from users
struct StepsRecord: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
}

struct StepsDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Chart state
    @State private var selectedTimeFrame: TimeFrame = .day
    @State private var selectedBarIndex: Int? = nil
    
    // Chart data per time frame
    @State private var dayChartData: [ChartDataPoint] = []
    @State private var weekChartData: [ChartDataPoint] = []
    @State private var monthChartData: [ChartDataPoint] = []
    @State private var yearChartData: [ChartDataPoint] = []
    
    // Performance optimizations with cached values
    @State private var maxYValue: Int = 1000
    @State private var currentData: [ChartDataPoint] = []
    
    // Sample Steps data for the Steps chart
    @State private var allStepsRecords: [StepsRecord] = [
        // From a specific day
        StepsRecord(date: Date.from(year: 2025, month: 11, day: 28, hour: 16, minute: 0), steps: 10234),
        StepsRecord(date: Date.from(year: 2025, month: 11, day: 28, hour: 17, minute: 45), steps: 11876),
        // From other days
        StepsRecord(date: Date.from(year: 2025, month: 12, day: 30, hour: 14, minute: 0), steps: 8765),
        StepsRecord(date: Date.from(year: 2025, month: 12, day: 31, hour: 15, minute: 30), steps: 7432),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 0, minute: 30), steps: 45),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 1, minute: 15), steps: 12),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 3, minute: 0), steps: 8),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 5, minute: 45), steps: 234),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 7, minute: 30), steps: 567),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 9, minute: 20), steps: 432),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 11, minute: 10), steps: 678),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 13, minute: 0), steps: 543),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 15, minute: 30), steps: 789),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 17, minute: 45), steps: 921),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 19, minute: 20), steps: 654),
        StepsRecord(date: Date.from(year: 2026, month: 1, day: 1, hour: 21, minute: 10), steps: 321),
    ]
    
    // Activity ring values
    let caloriesCurrent: Double = 4790
    let caloriesTarget: Double = 8000
    let exerciseCurrent: Double = 50
    let exerciseTarget: Double = 30
    let standCurrent: Double = 3
    let standTarget: Double = 12
    
    // Activity ring progress values
    var caloriesProgress: Double { min(caloriesCurrent / caloriesTarget, 1.0) }
    var exerciseProgress: Double { min(exerciseCurrent / exerciseTarget, 1.0) }
    var standProgress: Double { min(standCurrent / standTarget, 1.0) }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    activityRingsSection
                    timeFrameButtons
                    stepsTrackerSection
                    trendsAndInsightsSection
                    Spacer(minLength: 50)
                }
                .padding(.top, 16)
            }
            .background(Color.white)
        }
        .onAppear {
            initializeChartData()
            refreshForTimeFrame()
        }
        .onChange(of: selectedTimeFrame) { _, _ in
            // Animate spacer height change when switching time frames (dismisses any active popover)
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedBarIndex = nil
            }
            refreshForTimeFrame()
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps & Activity")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.proPrimary)
                    Text("Your Steps & Activities is monitored through your watch which is in sync with the app.")
                        .font(.subheadline)
                        .foregroundColor(Color.darkGrayText)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Activity Rings Section
    private var activityRingsSection: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                Circle().stroke(Color.proPrimary.opacity(0.15), lineWidth: 12).frame(width: 160, height: 160)
                Circle().trim(from: 0, to: caloriesProgress)
                    .stroke(Color.proPrimary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                Circle().stroke(Color.proTertiary.opacity(0.15), lineWidth: 12).frame(width: 120, height: 120)
                Circle().trim(from: 0, to: exerciseProgress)
                    .stroke(Color.proTertiary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                Circle().stroke(Color.proSecondary.opacity(0.15), lineWidth: 12).frame(width: 80, height: 80)
                Circle().trim(from: 0, to: standProgress)
                    .stroke(Color.proSecondary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
            }
            .padding(.leading, 30)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 24) {
                statisticBlock(title: "Move", value: "\(Int(caloriesCurrent))/\(Int(caloriesTarget))", subtitle: "Calories Burned", color: .proPrimary)
                statisticBlock(title: "Exercise", value: "\(Int(exerciseCurrent))/\(Int(exerciseTarget))", subtitle: "Minutes Moving", color: .proTertiary)
                statisticBlock(title: "Stand", value: "\(Int(standCurrent))/\(Int(standTarget))", subtitle: "Hours Standing", color: .proSecondary)
            }
            .frame(maxWidth: 160)
            .padding(.trailing, 18)
        }
    }
    
    // MARK: - Time Frame Buttons
    private var timeFrameButtons: some View {
        HStack(spacing: 12) {
            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    selectedTimeFrame = timeFrame
                }) {
                    Text(timeFrame.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTimeFrame == timeFrame ? .white : Color(red: 0.5, green: 0.5, blue: 0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(selectedTimeFrame == timeFrame ? Color.proSecondary : Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Steps Tracker Section
    private var stepsTrackerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Chart Card with title inside
            VStack(alignment: .leading, spacing: 0) {
                // Chart title
                Text("Steps Tracker")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.proPrimary)
                
                // Dynamically adjust height of empty space for popover to appear without overlapping any text
                Spacer()
                    .frame(height: selectedBarIndex != nil ? 60 : 15)
                    .animation(.easeInOut(duration: 0.3), value: selectedBarIndex)
                
                // Chart with integrated popover
                stepsChart
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Steps Chart
    private var stepsChart: some View {
        Chart {
            ForEach(Array(currentData.enumerated()), id: \.element.id) { index, point in
                let isSelected = selectedBarIndex == index
                
                BarMark(
                    x: .value("Label", point.label),
                    y: .value("Steps", point.steps)
                )
                .foregroundStyle(isSelected ? Color.proSecondary : Color.barDefault)
                .cornerRadius(4)
                
                // Popover annotation and connecting line for selected bar
                if isSelected {
                    // Vertical dashed line from popover to bar
                    RuleMark(x: .value("Label", point.label))
                        .foregroundStyle(Color.proSecondary)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                        .annotation(position: .top, alignment: .center, spacing: 0) {
                            stepsTooltip(steps: point.steps)
                        }
                }
            }
        }
        .frame(height: 260) // Extra height to accommodate popover
        .chartXAxis {
            if selectedTimeFrame == .month {
                // For month mode, only show labels at days 1, 7, 14, 21, 28
                AxisMarks { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                    if let label = value.as(String.self) {
                        let labelsToShow = ["1", "7", "14", "21", "28"]
                        if labelsToShow.contains(label) {
                            AxisValueLabel(verticalSpacing: 6)
                                .font(.system(size: xAxisFontSize))
                        }
                    }
                }
            } else {
                // For other modes, show all labels
                AxisMarks { value in
                    AxisValueLabel(verticalSpacing: 8)
                        .font(.system(size: xAxisFontSize))
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                AxisValueLabel(horizontalSpacing: 8)
            }
        }
        .chartYScale(domain: 0...(maxYValue + Int(Double(maxYValue) * 0.15))) // Extra space at top for popover
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
    
    private var xAxisFontSize: CGFloat {
        switch selectedTimeFrame {
        case .day:
            return 10
        case .week:
            return 12
        case .month:
            return 12
        case .year:
            return 10
        }
    }
    
    // MARK: - Steps Tooltip
    private func stepsTooltip(steps: Int) -> some View {
        VStack(spacing: 0) {
            // Popover
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatSteps(steps))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("steps")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.proSecondary)
            .cornerRadius(8)
            
            // Pointing triangle
            StepsPopoverArrow()
                .fill(Color.proSecondary)
                .frame(width: 12, height: 6)
        }
        .fixedSize()
    }
    
    // Format steps with comma separators for readability
    private func formatSteps(_ steps: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }
    
    // MARK: - Chart Tap Handler
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
        let dataCount = CGFloat(currentData.count)
        guard dataCount > 0 else { return }
        
        let barWidth = plotArea.width / dataCount
        let tappedIndex = Int(relativeX / barWidth)
        
        guard tappedIndex >= 0 && tappedIndex < currentData.count else {
            // Animate spacer height change when dismissing popover for invalid tap index
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
    
    // MARK: - Trends & Insights Section
    private var trendsAndInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends & Insights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.proPrimary)
                .padding(.horizontal, 24)
            
            // Horizontal scrolling trend cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    trendCard(
                        icon: "figure.walk",
                        value: "\(Int(exerciseCurrent))",
                        unit: "MIN/DAY",
                        description: "Compared to yesterday, your exercising duration has increased! Way to stay active!"
                    )
                    
                    trendCard(
                        icon: "figure.stand",
                        value: "\(Int(standCurrent))",
                        unit: "HR/DAY",
                        description: "On the way to supporting good posture"
                    )
                    
                    trendCard(
                        icon: "flame.fill",
                        value: "\(Int(caloriesCurrent))",
                        unit: "CAL",
                        description: "Calories burned today. Keep up the great work!"
                    )
                }
                .padding(.horizontal, 24)
            }
            
            // Insights
            VStack(alignment: .leading, spacing: 0) {
                StepsInsightRow(number: 1, text: "Your step count is 15% higher than last week's average", isLast: false)
                StepsInsightRow(number: 2, text: "Most active hours: 8 AM - 10 AM and 4 PM - 6 PM", isLast: false)
                StepsInsightRow(number: 3, text: "Try to maintain consistent activity throughout the day", isLast: true)
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 16)
    }
    
    // MARK: - Trend Card
    private func trendCard(icon: String, value: String, unit: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.proSecondary)
                    Text(unit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.darkGrayText)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.proPrimary)
            }
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.darkGrayText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Methods
    private func statisticBlock(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
    
    private func refreshForTimeFrame() {
        currentData = getChartData()
        maxYValue = computeMaxYValue(from: currentData)
    }
    
    private func computeMaxYValue(from data: [ChartDataPoint]) -> Int {
        let maxSteps = data.map { $0.steps }.max() ?? 0
        switch maxSteps {
        case 0...1000:     return ((maxSteps / 100) + 1) * 100
        case 1001...5000:  return ((maxSteps / 500) + 1) * 500
        case 5001...10000: return ((maxSteps / 1000) + 1) * 1000
        default:           return ((maxSteps / 10000) + 1) * 10000
        }
    }
    
    private func getChartData() -> [ChartDataPoint] {
        switch selectedTimeFrame {
        case .day: return dayChartData
        case .week: return weekChartData
        case .month: return monthChartData
        case .year: return yearChartData
        }
    }
    
    private func initializeChartData() {
        let calendar = Calendar.current
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        
        // Get all records for today with timestamps to be used for the Day mode of steps chart
        let todayRecords = allStepsRecords.filter { calendar.isDate($0.date, inSameDayAs: today) }
        
        // Day mode: hourly breakdown for today
        if !todayRecords.isEmpty {
            // Break up array literals for time-efficient compiler type-checks
            let hourLabelsPart1: [String] = ["12a", "2a", "4a", "6a"]
            let hourLabelsPart2: [String] = ["8a", "10a", "12p", "2p"]
            let hourLabelsPart3: [String] = ["4p", "6p", "8p", "10p"]
            let hourLabels = hourLabelsPart1 + hourLabelsPart2 + hourLabelsPart3
            
            // Each x-axis label in day mode chart defined in 2-hour intervals [startHour, endHour), with startHour and endHour both using 24-hour time format.
            // 12a = 0-2, 2a = 2-4, 4a = 4-6, 6a = 6-8, 8a = 8-10, 10a = 10-12,
            // 12p = 12-14, 2p = 14-16, 4p = 16-18, 6p = 18-20, 8p = 20-22, 10p = 22-24
            let intervalHours: [(start: Int, end: Int)] = [
                (0, 2), (2, 4), (4, 6), (6, 8), (8, 10), (10, 12),
                (12, 14), (14, 16), (16, 18), (18, 20), (20, 22), (22, 24)
            ]
            
            dayChartData = hourLabels.enumerated().map { index, label in
                let interval = intervalHours[index]
                // Sum all steps in this 2-hour interval
                let intervalSteps = todayRecords
                    .filter { record in
                        let hour = calendar.component(.hour, from: record.date)
                        return hour >= interval.start && hour < interval.end
                    }
                    .reduce(0) { $0 + $1.steps }
                
                return ChartDataPoint(id: UUID(), label: label, steps: intervalSteps, date: startOfToday)
            }
        } else {
            // Default placeholder data for day mode chart if today has no entry
            dayChartData = [
                ChartDataPoint(id: UUID(), label: "12a", steps: 45, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "2a", steps: 12, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "4a", steps: 8, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "6a", steps: 234, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "8a", steps: 567, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "10a", steps: 432, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "12p", steps: 678, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "2p", steps: 543, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "4p", steps: 789, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "6p", steps: 921, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "8p", steps: 654, date: startOfToday),
                ChartDataPoint(id: UUID(), label: "10p", steps: 321, date: startOfToday)
            ]
        }
        
        // Week mode: current week is last 7 days, including today
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: startOfToday) else {
            weekChartData = []
            return
        }
        
        let weekLabels = calendar.shortWeekdaySymbols
        weekChartData = (0..<7).compactMap { dayOffset in
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                return nil
            }
            let weekdayIndex = calendar.component(.weekday, from: currentDate) - 1
            let label = weekLabels[weekdayIndex]
            
            // Sum all records for this date
            let dayRecords = allStepsRecords.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
            let daySteps = dayRecords.reduce(0) { $0 + $1.steps }
            
            return ChartDataPoint(id: UUID(), label: label, steps: daySteps, date: currentDate)
        }
        
        // Month mode: all days in current month
        guard let monthInterval = calendar.dateInterval(of: .month, for: today) else {
            monthChartData = []
            return
        }
        
        var dates: [Date] = []
        var date = monthInterval.start
        while date < monthInterval.end {
            dates.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        monthChartData = dates.map { date in
            let day = calendar.component(.day, from: date)
            let label = "\(day)"
            
            // Sum all records for this date
            let dayRecords = allStepsRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let daySteps = dayRecords.reduce(0) { $0 + $1.steps }
            
            return ChartDataPoint(id: UUID(), label: label, steps: daySteps, date: date)
        }
        
        // Year mode: monthly aggregates for current year
        let months = calendar.shortMonthSymbols
        let currentYear = calendar.component(.year, from: today)
        yearChartData = (1...12).compactMap { monthNum in
            guard let monthDate = calendar.date(from: DateComponents(year: currentYear, month: monthNum, day: 1)) else {
                return nil
            }
            let label = months[monthNum - 1]
            
            // Sum all steps for this month
            guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
                return ChartDataPoint(id: UUID(), label: label, steps: 0, date: monthDate)
            }
            
            let monthSteps = allStepsRecords
                .filter { record in
                    record.date >= monthInterval.start && record.date < monthInterval.end
                }
                .reduce(0) { $0 + $1.steps }
            
            return ChartDataPoint(id: UUID(), label: label, steps: monthSteps, date: monthDate)
        }
    }
}

// MARK: - Supporting Structures & Extensions
private extension Color {
    static let proPrimary = Color.primaryGreen
    static let proSecondary = Color.secondaryGreen
    static let proTertiary = Color(red: 0.23, green: 0.51, blue: 0.36)
    static let barDefault = Color(red: 0.682, green: 0.698, blue: 0.788)
}

// MARK: - Popover Arrow Shape
struct StepsPopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

enum TimeFrame: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct ChartDataPoint: Identifiable {
    let id: UUID
    let label: String
    let steps: Int
    let date: Date
}

// MARK: - Insight Row Component
struct StepsInsightRow: View {
    let number: Int
    let text: String
    let isLast: Bool
    
    private let bulletBackgroundColor = Color(red: 240/255, green: 241/255, blue: 249/255)
    private let numberColor = Color.primaryGreen
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Text("\(number)")
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(numberColor)
                    .frame(width: 32, height: 32)
                    .background(bulletBackgroundColor)
                    .clipShape(Circle())
                
                Text(text)
                    .font(.custom("Noto Sans", size: 16))
                    .foregroundColor(Color.darkGrayText)
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
    StepsDetailsView()
}
