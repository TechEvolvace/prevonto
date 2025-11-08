// This is the Steps and Activity Page, which shows the user's calories burned, minutes moving, hours standing, and numbers of steps taken.
import SwiftUI
import Charts

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
            selectedBarIndex = nil
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
                        .foregroundColor(Color(red: 0.25, green: 0.33, blue: 0.44))
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
                Text("Steps Tracker")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.proPrimary)
                
                // Space for popover to appear without overlapping title
                Spacer().frame(height: 60)
                
                // Chart with integrated popover
                stepsChart
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
            AxisMarks { value in
                AxisValueLabel()
                    .font(.system(size: xAxisFontSize))
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
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
            return 8
        case .week:
            return 10
        case .month:
            return 9
        case .year:
            return 8
        }
    }
    
    // MARK: - Steps Tooltip (green background, white text, horizontal layout)
    private func stepsTooltip(steps: Int) -> some View {
        VStack(spacing: 0) {
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
            selectedBarIndex = nil
            return
        }
        
        // Calculate which bar was tapped based on position
        let dataCount = CGFloat(currentData.count)
        guard dataCount > 0 else { return }
        
        let barWidth = plotArea.width / dataCount
        let tappedIndex = Int(relativeX / barWidth)
        
        guard tappedIndex >= 0 && tappedIndex < currentData.count else {
            selectedBarIndex = nil
            return
        }
        
        if selectedBarIndex == tappedIndex {
            selectedBarIndex = nil
        } else {
            selectedBarIndex = tappedIndex
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
            
            HStack {
                VStack {
                    Text(value)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.proSecondary)
                    Text(unit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.grayText)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.proPrimary)
            }
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.grayText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
        dayChartData = [
            ChartDataPoint(id: UUID(), label: "12a", steps: 45, date: Date()),
            ChartDataPoint(id: UUID(), label: "2a", steps: 12, date: Date()),
            ChartDataPoint(id: UUID(), label: "4a", steps: 8, date: Date()),
            ChartDataPoint(id: UUID(), label: "6a", steps: 234, date: Date()),
            ChartDataPoint(id: UUID(), label: "8a", steps: 567, date: Date()),
            ChartDataPoint(id: UUID(), label: "10a", steps: 432, date: Date()),
            ChartDataPoint(id: UUID(), label: "12p", steps: 678, date: Date()),
            ChartDataPoint(id: UUID(), label: "2p", steps: 543, date: Date()),
            ChartDataPoint(id: UUID(), label: "4p", steps: 789, date: Date()),
            ChartDataPoint(id: UUID(), label: "6p", steps: 921, date: Date()),
            ChartDataPoint(id: UUID(), label: "8p", steps: 654, date: Date()),
            ChartDataPoint(id: UUID(), label: "10p", steps: 321, date: Date())
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
    static let grayText = Color(red: 0.25, green: 0.33, blue: 0.44)
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
    private let numberColor = Color(red: 0.01, green: 0.33, blue: 0.18)
    
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
    StepsDetailsView()
}
