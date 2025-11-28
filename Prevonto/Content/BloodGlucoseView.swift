// Blood Glucose page allows user to see their blood glucose levels by day, week, or month.
import SwiftUI
import Charts

// Properties of Blood Glucose data recorded from users
struct BloodGlucoseRecord {
    let timestamp: Date
    let glucoseLevel: Int // in mg/dl
}

// Specify whether user selects "Day", "Week", or "Month" view mode
enum BloodGlucoseChartMode: String, CaseIterable, Identifiable {
    case day, week, month
    var id: String { rawValue }
}

struct BloodGlucoseView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Default view mode selected is Day Mode
    @State private var selectedMode: BloodGlucoseChartMode = .day
    // Specify what date the user selected
    @State private var selectedDate: Date = Date()
    // Help identify which data point from chart is selected
    @State private var selectedDataIndex: Int? = nil
    // Week mode start and end date pickers
    @State private var showingStartDatePicker: Bool = false
    @State private var showingEndDatePicker: Bool = false
    @State private var weekStartDate: Date = Date()
    @State private var weekEndDate: Date = Date()
    
    // Sample Blood Glucose data
    private let allGlucoseRecords: [BloodGlucoseRecord] = [
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 10, day: 12, hour: 7, minute: 30), glucoseLevel: 95),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 10, day: 12, hour: 12, minute: 15), glucoseLevel: 120),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 13, hour: 13, minute: 30), glucoseLevel: 135),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 13, hour: 7, minute: 15), glucoseLevel: 92),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 9, minute: 30), glucoseLevel: 145),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 12, minute: 0), glucoseLevel: 130),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 15, minute: 45), glucoseLevel: 115),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 19, minute: 0), glucoseLevel: 105),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 15, hour: 7, minute: 45), glucoseLevel: 88),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 15, hour: 12, minute: 30), glucoseLevel: 140),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 16, hour: 8, minute: 15), glucoseLevel: 94),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 16, hour: 14, minute: 0), glucoseLevel: 128),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 17, hour: 7, minute: 30), glucoseLevel: 90),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 17, hour: 13, minute: 15), glucoseLevel: 132),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 18, hour: 8, minute: 0), glucoseLevel: 96),
        BloodGlucoseRecord(timestamp: Date.from(year: 2025, month: 11, day: 18, hour: 12, minute: 45), glucoseLevel: 125)
    ]
    
    // Sample data gets processed into suitable chart data to be displayed in the Chart for current selected view mode.
    private var chartData: [(index: Int, label: String, min: Int?, max: Int?)] {
        aggregateGlucose(
            for: allGlucoseRecords,
            mode: selectedMode,
            selectedDate: selectedDate,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate
        )
        .enumerated()
        .map { (idx, item) in (index: idx, label: item.label, min: item.min, max: item.max) }
    }
    
    // For day mode line chart, we need individual readings
    private var dayChartData: [(index: Int, hour: Int, value: Int)] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let filtered = allGlucoseRecords.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
        
        return filtered.enumerated().map { (idx, record) in
            let hour = calendar.component(.hour, from: record.timestamp)
            return (index: idx, hour: hour, value: record.glucoseLevel)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Headline
                    headerSection
                    
                    // Average Blood Glucose Card
                    averageGlucoseCard
                        .onTapGesture {
                            unselectChartData()
                        }
                    
                    // View Mode Picker
                    modePicker
                    
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
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.grayText)
                    }
                }
            }
        }
        .onAppear {
            updateWeekDates()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blood glucose")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryGreen)
            
            Text("Your blood glucose levels must be recorded by you on a bi-weekly basis.")
                .font(.subheadline)
                .foregroundColor(.grayText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .onTapGesture {
            unselectChartData()
        }
    }
    
    // MARK: - Average Glucose Card
    private var averageGlucoseCard: some View {
        VStack(spacing: 8) {
            Text("\(averageGlucose)")
                .font(.system(size: 42, weight: .semibold))
                .foregroundColor(Color.secondaryGreen)
            + Text(" mg/dl")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(Color.gray)
            
            Text(averageLabel)
                .font(.custom("Noto Sans", size: 16))
                .foregroundColor(.grayText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 0.15)
        }
        .padding(.bottom, 16)
    }
    
    private var averageGlucose: Int {
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
    
    // MARK: - Mode Picker
    private var modePicker: some View {
        HStack(spacing: 20) {
            ForEach(BloodGlucoseChartMode.allCases) { mode in
                Button(action: {
                    selectedMode = mode
                    selectedDataIndex = nil
                }) {
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
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Blood glucose (mg/dl) over time")
                .foregroundColor(Color.grayText)
                .font(.system(size: 18, weight: .medium))
                .padding(.bottom, 16)
            
            if selectedMode == .day {
                dayLineChart
            } else {
                barChart
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
        .padding(.bottom, 20)
        .onChange(of: selectedMode) { _, _ in
            // Dismiss selection when switching modes
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedDataIndex = nil
            }
        }
    }
    
    // MARK: - Day Line Chart
    private var dayLineChart: some View {
        Chart {
            // Always show placeholder points to ensure x-axis is visible even with no data
            ForEach([0, 6, 12, 18], id: \.self) { hour in
                PointMark(
                    x: .value("Hour", hour),
                    y: .value("mg/dl", 0)
                )
                .foregroundStyle(.clear)
            }
            
            // Actual data points
            ForEach(dayChartData, id: \.index) { data in
                LineMark(
                    x: .value("Hour", data.hour),
                    y: .value("mg/dl", data.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.glucoseLineBlue)
                
                PointMark(
                    x: .value("Hour", data.hour),
                    y: .value("mg/dl", data.value)
                )
                .foregroundStyle(selectedDataIndex == data.index ? Color.selectionGreen : Color.glucoseLineBlue)
                .symbolSize(selectedDataIndex == data.index ? 100 : 60)
                .annotation(position: .top, alignment: .center, spacing: 4) {
                    if selectedDataIndex == data.index {
                        dayTooltip(for: data)
                    }
                }
            }
        }
        .frame(height: 250)
        .chartXAxis {
            AxisMarks(values: [0, 3, 6, 9, 12, 15, 18, 21]) { value in
                if let hour = value.as(Int.self) {
                    AxisValueLabel(horizontalSpacing: -5, verticalSpacing: 16) {
                        Text(hourLabel(for: hour))
                            .font(.system(size: 12))
                    }
                    AxisTick(length: 12, stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                AxisValueLabel(horizontalSpacing: 16)
            }
        }
        .chartXScale(domain: 0...23)
        .chartYScale(domain: 0...220)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        handleDayChartTap(at: location, proxy: proxy, geometry: geometry)
                    }
            }
        }
    }
    
    private func hourLabel(for hour: Int) -> String {
        if hour == 0 { return "12a" }
        else if hour < 12 { return "\(hour)a" }
        else if hour == 12 { return "12p" }
        else { return "\(hour - 12)p" }
    }
    
    // White popover tooltip for day mode
    private func dayTooltip(for data: (index: Int, hour: Int, value: Int)) -> some View {
        VStack(spacing: 0) {
            // Main content box
            VStack(spacing: 0) {
                Text("\(data.value)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryGreen)
                Text("mg/dl")
                    .font(.system(size: 10))
                    .foregroundColor(.grayText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            // Pointing triangle
            GlucosePopoverArrow()
                .fill(Color.white)
                .frame(width: 12, height: 6)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
    }
    
    private func handleDayChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard !dayChartData.isEmpty else { return }
        guard let plotFrame = proxy.plotFrame else { return }
        
        let plotArea = geometry[plotFrame]
        
        // Check if tap is within the plot area
        let relativeX = location.x - plotArea.origin.x
        let relativeY = location.y - plotArea.origin.y
        
        guard relativeX >= 0 && relativeX <= plotArea.width &&
              relativeY >= 0 && relativeY <= plotArea.height else {
            // Dismissing selection by tapping outside chart
            selectedDataIndex = nil
            return
        }
        
        // Find closest data point using precise plot area coordinates
        var closestIndex: Int? = nil
        var closestDistance: CGFloat = .infinity
        
        for data in dayChartData {
            // Get the x position of this data point in plot coordinates
            if let xPos = proxy.position(forX: data.hour) {
                // Calculate distance from tap location to data point
                // Only consider x distance for horizontal precision
                let distance = abs(xPos - relativeX)
                
                // Use a reasonable threshold (40 points) for tap precision
                if distance < closestDistance && distance < 40 {
                    closestDistance = distance
                    closestIndex = data.index
                }
            }
        }
        
        // Handle showing/dismissing selection on point tap
        if let index = closestIndex {
            if selectedDataIndex == index {
                selectedDataIndex = nil
            } else {
                selectedDataIndex = index
            }
        } else {
            selectedDataIndex = nil
        }
    }
    
    // MARK: - Bar Chart (for Week or Month mode)
    private var barChart: some View {
        VStack(alignment: .leading, spacing: 0) {
            Chart {
                ForEach(chartData.indices, id: \.self) { idx in
                    let data = chartData[idx]
                    let isSelected = selectedDataIndex == idx
                    
                    if let min = data.min, let max = data.max {
                        if min == max {
                            // Point mark for single values (when min == max)
                            PointMark(
                                x: .value("Label", data.label),
                                y: .value("Measurement", min)
                            )
                            .foregroundStyle(isSelected ? Color.secondaryGreen : Color.barDefault)
                            .symbolSize(60)
                            .annotation(position: .top, alignment: .center, spacing: 4) {
                                if isSelected {
                                    maxValueLabel(value: min)
                                }
                            }
                            .annotation(position: .bottom, alignment: .center, spacing: 4) {
                                if isSelected {
                                    minValueLabel(value: min)
                                }
                            }
                        } else {
                            // Bar mark extending from min to max
                            BarMark(
                                x: .value("Label", data.label),
                                yStart: .value("Min", min),
                                yEnd: .value("Max", max)
                            )
                            .foregroundStyle(isSelected ? Color.secondaryGreen : Color.barDefault)
                            .cornerRadius(4)
                            
                            // Show max value label above the bar when selected
                            if isSelected {
                                PointMark(
                                    x: .value("Label", data.label),
                                    y: .value("Max", max)
                                )
                                .foregroundStyle(.clear)
                                .annotation(position: .top, alignment: .center, spacing: 8) {
                                    maxValueLabel(value: max)
                                }
                                
                                // Show min value label below the bar when selected
                                PointMark(
                                    x: .value("Label", data.label),
                                    y: .value("Min", min)
                                )
                                .foregroundStyle(.clear)
                                .annotation(position: .bottom, alignment: .center, spacing: 4) {
                                    minValueLabel(value: min)
                                }
                            }
                        }
                    } else {
                        // When there's no data
                        BarMark(
                            x: .value("Label", data.label),
                            yStart: .value("Min", 0),
                            yEnd: .value("Max", 0)
                        )
                        .foregroundStyle(.clear)
                    }
                }
            }
            .frame(height: 260) // Extra height to accommodate labels
            .chartXAxis {
                if selectedMode == .month {
                    // For month mode, only show labels at days 1, 7, 14, 21, 28
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                        if let label = value.as(String.self) {
                            let labelsToShow = ["1", "7", "14", "21", "28"]
                            if labelsToShow.contains(label) {
                                AxisValueLabel(verticalSpacing: 8)
                                    .font(.system(size: xAxisFontSize))
                            }
                        }
                    }
                } else {
                    // For week mode, show all labels
                    AxisMarks { value in
                        AxisValueLabel(verticalSpacing: 12)
                            .font(.system(size: xAxisFontSize))
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                    AxisValueLabel(horizontalSpacing: 16)
                }
            }
            .chartYScale(domain: 0...220)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            handleBarChartTap(at: location, proxy: proxy, geometry: geometry)
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
    
    // Max value label shown above bar
    private func maxValueLabel(value: Int) -> some View {
        VStack(spacing: 0) {
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.secondaryGreen)
            Text("mg/dl")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.secondaryGreen)
        }
    }
    
    // Min value label shown below bar
    private func minValueLabel(value: Int) -> some View {
        VStack(spacing: 0) {
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.secondaryGreen)
            Text("mg/dl")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.secondaryGreen)
        }
    }
    
    
    // Handle tap on chart using precise plotFrame calculation
    private func handleBarChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let plotArea = geometry[plotFrame]
        
        // Check if tap is within the plot area
        let relativeX = location.x - plotArea.origin.x
        
        guard relativeX >= 0 && relativeX <= plotArea.width else {
            // Animate spacer height change when dismissing selection by tapping outside chart
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedDataIndex = nil
            }
            return
        }
        
        // Calculate which bar was tapped based on position
        let dataCount = CGFloat(chartData.count)
        guard dataCount > 0 else { return }
        
        let barWidth = plotArea.width / dataCount
        let tappedIndex = Int(relativeX / barWidth)
        
        guard tappedIndex >= 0 && tappedIndex < chartData.count else {
            // Animate spacer height change when dismissing selection for invalid tap index
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedDataIndex = nil
            }
            return
        }
        
        // Check if this data point has data
        let data = chartData[tappedIndex]
        if data.min == nil || data.max == nil {
            // If tapping on a bar with no data, just deselect any current selection
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedDataIndex = nil
            }
            return
        }
        
        // Animate spacer height change when showing/dismissing selection on bar tap
        withAnimation(.easeInOut(duration: 0.3)) {
            if selectedDataIndex == tappedIndex {
                selectedDataIndex = nil
            } else {
                selectedDataIndex = tappedIndex
            }
        }
    }
    
    private func unselectChartData() {
        selectedDataIndex = nil
    }
    
    // MARK: - Date Navigation Section
    private var dateNavigationSection: some View {
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
            selectedDataIndex = nil
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
        }
        .buttonStyle(PlainButtonStyle())
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.3)
        }
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
                weekDatePickerView(for: $weekStartDate, isStartDate: true)
                    .background(
                        Color.black.opacity(0.001)
                            .onTapGesture {
                                dismissStartDatePicker()
                            }
                    )
            }
            
            if showingEndDatePicker {
                weekDatePickerView(for: $weekEndDate, isStartDate: false)
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
    
    private func weekDatePickerView(for binding: Binding<Date>, isStartDate: Bool) -> some View {
        DatePicker(
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
            let calendar = Calendar.current
            if isStartDate {
                if let newEndDate = calendar.date(byAdding: .day, value: 6, to: newDate) {
                    weekEndDate = newEndDate
                }
            } else {
                if let newStartDate = calendar.date(byAdding: .day, value: -6, to: newDate) {
                    weekStartDate = newStartDate
                }
            }
            updateSelectedDateFromWeek()
        }
    }
    
    // MARK: - Highlights Section
    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Highlights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            if hasData {
                VStack(alignment: .leading, spacing: 0) {
                    GlucoseHighlightRow(number: 1, text: "Your glucose levels are within normal range", isLast: false)
                    GlucoseHighlightRow(number: 2, text: "Post-meal spikes observed between 12pm-2pm", isLast: true)
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
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            if hasData {
                VStack(alignment: .leading, spacing: 0) {
                    GlucoseInsightRow(number: 1, text: "Consider reducing carbohydrate intake at lunch", isLast: false)
                    GlucoseInsightRow(number: 2, text: "Maintain your current breakfast routine", isLast: true)
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
    
    private var hasData: Bool {
        if selectedMode == .day {
            return !dayChartData.isEmpty
        } else {
            return chartData.contains { $0.min != nil && $0.max != nil }
        }
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
            selectedDataIndex = nil
            
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
        selectedDate = weekStartDate
    }
}

// MARK: - Colors used for the Blood Glucose page
private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)
    static let grayText = Color(red: 0.25, green: 0.33, blue: 0.44)
    static let tintedShadow = Color("Pale Slate Shadow")
    
    // #608E61 for selection highlight
    static let selectionGreen = Color(red: 96/255, green: 142/255, blue: 97/255)
    // Blue color for day mode line chart
    static let glucoseLineBlue = Color.blue.opacity(0.7)
    // #AEB2C9 for unselected bars in week/month mode
    static let unselectedBar = Color(red: 174/255, green: 178/255, blue: 201/255)
    // #AEB2C9 equivalent - barDefault color matching HeartRateView
    static let barDefault = Color(red: 0.682, green: 0.698, blue: 0.788)
}

// MARK: - Popover Arrow Shape
struct GlucosePopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Data Aggregation
func aggregateGlucose(for records: [BloodGlucoseRecord],
                      mode: BloodGlucoseChartMode,
                      selectedDate: Date,
                      weekStartDate: Date,
                      weekEndDate: Date) -> [(label: String, min: Int?, max: Int?)] {
    let calendar = Calendar.current
    let now = Date()
    
    switch mode {
    case .day:
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let filtered = records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
        let grouped = Dictionary(grouping: filtered) { calendar.component(.hour, from: $0.timestamp) }
        
        return (0..<24).map { hour in
            let label = String(format: "%02d:00", hour)
            if calendar.isDate(selectedDate, inSameDayAs: now),
               hour > calendar.component(.hour, from: now) {
                return (label, nil as Int?, nil as Int?)
            }
            if let data = grouped[hour], !data.isEmpty {
                return (label, data.map(\.glucoseLevel).min(), data.map(\.glucoseLevel).max())
            } else {
                return (label, nil as Int?, nil as Int?)
            }
        }
        
    case .week:
        let startOfWeek = calendar.startOfDay(for: weekStartDate)
        let endOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: weekEndDate)!)
        
        let filtered = records.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek && $0.timestamp <= now }
        
        let groupedByDate = Dictionary(grouping: filtered) { record -> Date in
            calendar.startOfDay(for: record.timestamp)
        }
        
        return (0..<7).map { dayOffset in
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
                return ("", nil as Int?, nil as Int?)
            }
            
            let weekdayIndex = calendar.component(.weekday, from: currentDate) - 1
            let label = calendar.shortWeekdaySymbols[weekdayIndex]
            
            if currentDate > now {
                return (label, nil as Int?, nil as Int?)
            }
            
            if let data = groupedByDate[currentDate], !data.isEmpty {
                let values = data.map(\.glucoseLevel)
                return (label, values.min(), values.max())
            } else {
                return (label, nil as Int?, nil as Int?)
            }
        }
        
    case .month:
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let dayRange = calendar.range(of: .day, in: .month, for: selectedDate)
        else { return [] }
        
        let filtered = records.filter { monthInterval.contains($0.timestamp) && $0.timestamp <= now }
        let grouped = Dictionary(grouping: filtered) { calendar.component(.day, from: $0.timestamp) }
        
        return dayRange.map { day in
            let label = "\(day)"
            if calendar.isDate(selectedDate, equalTo: now, toGranularity: .month) &&
                day > calendar.component(.day, from: now) {
                return (label, nil as Int?, nil as Int?)
            }
            if let data = grouped[day], !data.isEmpty {
                return (label, data.map(\.glucoseLevel).min(), data.map(\.glucoseLevel).max())
            } else {
                return (label, nil as Int?, nil as Int?)
            }
        }
    }
}

// MARK: - Highlight Row Component
struct GlucoseHighlightRow: View {
    let number: Int
    let text: String
    let isLast: Bool
    
    // #F0F1F9 converted to RGB (240/255, 241/255, 249/255)
    private let bulletBackgroundColor = Color(red: 240/255, green: 241/255, blue: 249/255)
    // Numbered bullet point text color
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
struct GlucoseInsightRow: View {
    let number: Int
    let text: String
    let isLast: Bool
    
    // #F0F1F9 converted to RGB (240/255, 241/255, 249/255)
    private let bulletBackgroundColor = Color(red: 240/255, green: 241/255, blue: 249/255)
    // Same color as "Blood glucose" title
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
    BloodGlucoseView()
}
