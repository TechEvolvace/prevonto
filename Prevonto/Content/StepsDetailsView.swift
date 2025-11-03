// This is the Steps and Activity Page, which shows the user's calories burned, minutes moving, hours standing, and numbers of steps taken.
import SwiftUI
import Charts

struct StepsDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Chart state
    @State private var selectedTimeFrame: TimeFrame = .day
    @State private var selectedDataPoint: ChartDataPoint?
    
    // Chart data per time frame
    @State private var dayChartData: [ChartDataPoint] = []
    @State private var weekChartData: [ChartDataPoint] = []
    @State private var monthChartData: [ChartDataPoint] = []
    @State private var yearChartData: [ChartDataPoint] = []
    
    // Performance optimizations: cached values
    @State private var maxYValue: Int = 1000
    @State private var currentData: [ChartDataPoint] = []
    
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
    
    // Day Mode spacing factor
    private var dayModeSpacingFactor: Double { 1.5 }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        titleSection
                        activityRingsSection
                        timeFrameButtons
                        stepsTrackerHeading
                        chartDisplayContainer
                        trendSection // <--- New Section for Trends
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .onAppear {
            initializeChartData()
            refreshForTimeFrame()
        }
        .onChange(of: selectedTimeFrame) { _, _ in
            selectedDataPoint = nil
            refreshForTimeFrame()
        }
    }
    
    // MARK: - Trend Section
    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("✨ Motivation & Trends")
                .font(.headline)
                .foregroundColor(.proPrimary)
            trendRows
        }
        .padding(.top, 10)
        .padding(.horizontal, 24)
    }
    
    private var trendRows: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Calculations based on ring progress and chart data
            let movePercent = Int((caloriesCurrent / caloriesTarget) * 100)
            let exercisePercent = Int((exerciseCurrent / exerciseTarget) * 100)
            let standPercent = Int((standCurrent / standTarget) * 100)
            
            let averageSteps = currentData.isEmpty ? 0 : currentData.map { $0.steps }.reduce(0, +) / currentData.count
            let maxSteps = currentData.map { $0.steps }.max() ?? 0
            let lastIndex = currentData.indices.last ?? 0
            let lastSteps = currentData.isEmpty ? 0 : currentData[lastIndex].steps
            let prevSteps = currentData.count > 1 ? currentData[lastIndex - 1].steps : 0
            let stepsDelta = lastSteps - prevSteps
            let stepsTrend = stepsDelta == 0 ? "no change" : stepsDelta > 0 ? "▲ up" : "▼ down"
            
            Group {
                Text("• You achieved **\(movePercent)%** of your Move goal (\(Int(caloriesCurrent))/\(Int(caloriesTarget)) calories).")
                Text("• You reached **\(exercisePercent)%** of your Exercise goal (\(Int(exerciseCurrent))/\(Int(exerciseTarget)) minutes).")
                Text("• You reached **\(standPercent)%** of your Stand goal (\(Int(standCurrent))/\(Int(standTarget)) hours).")
                Divider().padding(.vertical, 2)
                Text("• Avg. steps this period: **\(averageSteps)**")
                Text("• Highest steps in a bar: **\(maxSteps)**")
                if currentData.count > 1 {
                    Text("• Last interval: **\(lastSteps) steps** (\(stepsTrend) \(abs(stepsDelta)))")
                }
                // Motivation suggestions
                if movePercent < 100 || exercisePercent < 100 || standPercent < 100 {
                    Text("🔥 Keep moving! Small efforts add up. You're making progress — just a little more to hit your next goal!")
                } else {
                    Text("🎉 Fantastic! You've smashed your activity goals. Stay consistent to keep building healthy habits!")
                }
            }
            .font(.subheadline)
        }
    }
    
    // MARK: - View Components
    private var titleSection: some View { /* ... unchanged ... */ VStack(alignment: .leading, spacing: 12) {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Steps & Activity")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.proPrimary)
                Text("Your Steps & Activities is monitored through your watch which is in sync with the app.")
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.25, green: 0.33, blue: 0.44))
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    } }
    
    private var activityRingsSection: some View { /* ... unchanged ... */
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
            .alignmentGuide(.leading) { d in d[.leading] - 80 }
            .padding(.leading, 30)
            Spacer()
            VStack(alignment: .leading, spacing: 24) {
                statisticBlock(
                    title: "Move",
                    value: "\(Int(caloriesCurrent))/\(Int(caloriesTarget))",
                    subtitle: "Calories Burned",
                    color: .proPrimary
                )
                statisticBlock(
                    title: "Exercise",
                    value: "\(Int(exerciseCurrent))/\(Int(exerciseTarget))",
                    subtitle: "Minutes Moving",
                    color: .proTertiary
                )
                statisticBlock(
                    title: "Stand",
                    value: "\(Int(standCurrent))/\(Int(standTarget))",
                    subtitle: "Hours Standing",
                    color: .proSecondary
                )
            }
            .frame(maxWidth: 160)
            .padding(.trailing, 18)
        }
    }
    
    private var timeFrameButtons: some View { /* ... unchanged ... */ HStack {
        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
            Button(action: {
                selectedTimeFrame = timeFrame
            }) {
                Text(timeFrame.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedTimeFrame == timeFrame ? .white : Color(red: 0.5, green: 0.5, blue: 0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(selectedTimeFrame == timeFrame ? Color.proTertiary : Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            if timeFrame != TimeFrame.allCases.last {
                Spacer()
            }
        }
    }
    .padding(.horizontal, 24)
    }
    
    private var stepsTrackerHeading: some View { /* ... unchanged ... */ HStack {
        Text("Steps Tracker")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.proPrimary)
        Spacer()
    }
    .padding(.horizontal, 24)
    }
    
    // MARK: - Chart Implementation with Centered Message Box
    private var chartDisplayContainer: some View { /* ... unchanged ... */
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Rectangle().fill(Color.clear).frame(height: 80)
                if let selectedPoint = selectedDataPoint {
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Text("\(selectedPoint.steps)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("steps")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.proTertiary)
                        .cornerRadius(8)
                        .overlay(
                            Triangle()
                                .fill(Color.proTertiary)
                                .frame(width: 10, height: 6)
                                .offset(y: 8),
                            alignment: .bottom
                        )
                        Spacer()
                    }
                    .frame(height: 80)
                }
            }
            chartSection
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
    
    private var chartSection: some View { /* ... unchanged ... */ VStack(spacing: 12) {
        Chart {
            ForEach(0..<(currentData.count + 1), id: \.self) { index in
                RuleMark(x: .value("Boundary", getBoundaryPosition(for: index)))
                    .foregroundStyle(Color.boundary)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
            }
            ForEach(Array(currentData.enumerated()), id: \.element.id) { index, point in
                BarMark(
                    x: .value("Position", getBarPosition(for: index)),
                    y: .value("Steps", point.steps)
                )
                .foregroundStyle(selectedDataPoint?.id == point.id ? Color.proTertiary : Color.barDefault)
                .cornerRadius(2)
            }
        }
        .chartYScale(domain: 0...maxYValue)
        .chartXScale(domain: getXAxisDomain())
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                    .foregroundStyle(Color.gray.opacity(0.3))
                AxisValueLabel()
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .chartXAxis {
            if selectedTimeFrame == .day {
                AxisMarks { _ in
                    AxisValueLabel("")
                }
            } else {
                AxisMarks(values: .stride(by: 1)) { value in
                    if let index = value.as(Int.self),
                       index >= 0 && index < currentData.count {
                        AxisValueLabel(currentData[index].label)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .frame(height: 200)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        handleChartTap(at: location, proxy: proxy, geometry: geometry)
                    }
            }
        }
        if selectedTimeFrame == .day {
            enhancedDayModeLabels
        }
    }
    .padding(16)
    }
    
    // MARK: - Enhanced Day Mode Labels with Proper Spacing
    private var enhancedDayModeLabels: some View { /* ... unchanged ... */
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<12, id: \.self) { index in
                    Group {
                        switch index {
                        case 3: Text("6 AM")
                        case 6: Text("12 PM")
                        case 9: Text("6 PM")
                        default: Text("")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.gray)
                    if index < 11 {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            HStack {
                Image(systemName: "sun.max")
                    .foregroundColor(.gray)
                    .font(.title2)
                Spacer()
                Image(systemName: "moon")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Spacing Helper Methods
    private func getBoundaryPosition(for index: Int) -> Double {
        if selectedTimeFrame == .day {
            return Double(index) * dayModeSpacingFactor
        } else {
            return Double(index)
        }
    }
    private func getBarPosition(for index: Int) -> Double {
        if selectedTimeFrame == .day {
            return (Double(index) + 0.5) * dayModeSpacingFactor
        } else {
            return Double(index) + 0.5
        }
    }
    private func getXAxisDomain() -> ClosedRange<Double> {
        if selectedTimeFrame == .day {
            let maxPosition = Double(currentData.count) * dayModeSpacingFactor
            return 0...maxPosition
        } else {
            return 0...Double(currentData.count)
        }
    }
    
    // MARK: - Enhanced Chart Interaction with Spacing
    private func handleChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let frame = geometry[plotFrame]
        let plotX = location.x - frame.origin.x
        guard let xValue = proxy.value(atX: plotX, as: Double.self) else { return }
        let barIndex: Int
        if selectedTimeFrame == .day {
            barIndex = Int(round((xValue / dayModeSpacingFactor) - 0.5))
        } else {
            barIndex = Int(round(xValue - 0.5))
        }
        guard barIndex >= 0 && barIndex < currentData.count else { return }
        let tappedDataPoint = currentData[barIndex]
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDataPoint = (selectedDataPoint?.id == tappedDataPoint.id) ? nil : tappedDataPoint
        }
    }
    
    // MARK: - Performance Helper Methods
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
    private func initializeChartData() {
        dayChartData = [
            ChartDataPoint(id: UUID(), label: "12am", steps: 45, date: Date()),
            ChartDataPoint(id: UUID(), label: "2am", steps: 12, date: Date()),
            ChartDataPoint(id: UUID(), label: "4am", steps: 8, date: Date()),
            ChartDataPoint(id: UUID(), label: "6am", steps: 234, date: Date()),
            ChartDataPoint(id: UUID(), label: "8am", steps: 567, date: Date()),
            ChartDataPoint(id: UUID(), label: "10am", steps: 432, date: Date()),
            ChartDataPoint(id: UUID(), label: "12pm", steps: 678, date: Date()),
            ChartDataPoint(id: UUID(), label: "2pm", steps: 543, date: Date()),
            ChartDataPoint(id: UUID(), label: "4pm", steps: 789, date: Date()),
            ChartDataPoint(id: UUID(), label: "6pm", steps: 921, date: Date()),
            ChartDataPoint(id: UUID(), label: "8pm", steps: 654, date: Date()),
            ChartDataPoint(id: UUID(), label: "10pm", steps: 321, date: Date())
        ]
        weekChartData = [
            ChartDataPoint(id: UUID(), label: "Sun", steps: 5432, date: Date()),
            ChartDataPoint(id: UUID(), label: "Mon", steps: 7834, date: Date()),
            ChartDataPoint(id: UUID(), label: "Tue", steps: 6542, date: Date()),
            ChartDataPoint(id: UUID(), label: "Wed", steps: 8765, date: Date()),
            ChartDataPoint(id: UUID(), label: "Thu", steps: 5432, date: Date()),
            ChartDataPoint(id: UUID(), label: "Fri", steps: 9876, date: Date()),
            ChartDataPoint(id: UUID(), label: "Sat", steps: 4321, date: Date())
        ]
        monthChartData = [
            ChartDataPoint(id: UUID(), label: "Week 1", steps: 45321, date: Date()),
            ChartDataPoint(id: UUID(), label: "Week 2", steps: 52145, date: Date()),
            ChartDataPoint(id: UUID(), label: "Week 3", steps: 48967, date: Date()),
            ChartDataPoint(id: UUID(), label: "Week 4", steps: 51234, date: Date())
        ]
        yearChartData = [
            ChartDataPoint(id: UUID(), label: "Jan", steps: 198765, date: Date()),
            ChartDataPoint(id: UUID(), label: "Feb", steps: 176543, date: Date()),
            ChartDataPoint(id: UUID(), label: "Mar", steps: 203456, date: Date()),
            ChartDataPoint(id: UUID(), label: "Apr", steps: 187654, date: Date()),
            ChartDataPoint(id: UUID(), label: "May", steps: 214567, date: Date()),
            ChartDataPoint(id: UUID(), label: "Jun", steps: 195432, date: Date()),
            ChartDataPoint(id: UUID(), label: "Jul", steps: 189876, date: Date()),
            ChartDataPoint(id: UUID(), label: "Aug", steps: 0, date: Date()),
            ChartDataPoint(id: UUID(), label: "Sep", steps: 0, date: Date()),
            ChartDataPoint(id: UUID(), label: "Oct", steps: 0, date: Date()),
            ChartDataPoint(id: UUID(), label: "Nov", steps: 0, date: Date()),
            ChartDataPoint(id: UUID(), label: "Dec", steps: 0, date: Date())
        ]
    }
}

// MARK: - Supporting Structures & Extensions

private extension Color {
    static let proPrimary = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let proSecondary = Color(red: 0.39, green: 0.59, blue: 0.38)
    static let proTertiary = Color(red: 0.23, green: 0.51, blue: 0.36)
    static let barDefault = Color(red: 0.682, green: 0.698, blue: 0.788)
    static let boundary = Color(red: 0.839, green: 0.871, blue: 0.929).opacity(0.4)
}

struct Triangle: Shape {
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

struct StepsDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        StepsDetailsView()
    }
}

