// SpO2 page displays the user's SpO2 levels across days, weeks or months.
import SwiftUI
import Charts

// Properties of SpO2 data recorded from users
struct SpO2Record {
    let timestamp: Date
    let spO2Level: Double // in percentage
}

struct SpO2View: View {
    @State private var selectedTab = "Week"
    @State private var selectedDate: Date = Date.from(year: 2025, month: 11, day: 14)
    @State private var avgHeartRate = 60.0
    @State private var selectedDataIndex: Int? = nil
    // Week mode start and end date pickers
    @State private var showingStartDatePicker: Bool = false
    @State private var showingEndDatePicker: Bool = false
    @State private var weekStartDate: Date = Date.from(year: 2025, month: 11, day: 14)
    @State private var weekEndDate: Date = Date.from(year: 2025, month: 11, day: 14)
    
    // Sample SpO2 data for November 2025
    private let allSpO2Records: [SpO2Record] = [
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 13, hour: 7, minute: 30), spO2Level: 95),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 13, hour: 12, minute: 15), spO2Level: 96),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 13, hour: 18, minute: 45), spO2Level: 94),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 6, minute: 0), spO2Level: 95),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 9, minute: 30), spO2Level: 96),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 12, minute: 0), spO2Level: 95),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 15, minute: 45), spO2Level: 90),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 14, hour: 19, minute: 0), spO2Level: 92),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 15, hour: 7, minute: 45), spO2Level: 96),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 15, hour: 13, minute: 30), spO2Level: 99),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 16, hour: 8, minute: 15), spO2Level: 94),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 16, hour: 14, minute: 0), spO2Level: 96),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 17, hour: 7, minute: 30), spO2Level: 98),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 17, hour: 13, minute: 15), spO2Level: 98),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 18, hour: 8, minute: 0), spO2Level: 96),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 18, hour: 12, minute: 45), spO2Level: 92),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 19, hour: 9, minute: 20), spO2Level: 94),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 19, hour: 15, minute: 10), spO2Level: 91),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 20, hour: 7, minute: 0), spO2Level: 88),
        SpO2Record(timestamp: Date.from(year: 2025, month: 11, day: 20, hour: 11, minute: 30), spO2Level: 85)
    ]
    
    // Helper to get filtered records for current period
    private var filteredSpO2Records: [SpO2Record] {
        let calendar = Calendar.current
        if selectedTab == "Day" {
            let startOfDay = calendar.startOfDay(for: selectedDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return allSpO2Records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
        } else {
            let startOfWeek = calendar.startOfDay(for: weekStartDate)
            let endOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: weekEndDate)!)
            return allSpO2Records.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }
        }
    }
    
    // Check if there's data for the current period
    private var hasSpO2Data: Bool {
        !filteredSpO2Records.isEmpty
    }
    
    // Computed property for average SpO2
    private var avgSpO2: Double {
        let filtered = filteredSpO2Records
        guard !filtered.isEmpty else { return 0 }
        
        let sum = filtered.reduce(0.0) { $0 + $1.spO2Level }
        return sum / Double(filtered.count)
    }
    
    // Computed property for lowest SpO2
    private var computedLowestSpO2: Double {
        let filtered = filteredSpO2Records
        return filtered.map(\.spO2Level).min() ?? 0
    }
    
    // Week mode chart data
    private var weekChartData: [(index: Int, label: String, value: Double)] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: weekStartDate)
        let endOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: weekEndDate)!)
        
        let filtered = allSpO2Records.filter { $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek }
        
        let groupedByDate = Dictionary(grouping: filtered) { record -> Date in
            calendar.startOfDay(for: record.timestamp)
        }
        
        return (0..<7).map { dayOffset in
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
                return (index: dayOffset, label: "", value: 0.0)
            }
            
            let weekdayIndex = calendar.component(.weekday, from: currentDate) - 1
            let label = calendar.shortWeekdaySymbols[weekdayIndex]
            
            if let data = groupedByDate[currentDate], !data.isEmpty {
                // Average SpO2 for the day
                let avg = data.map(\.spO2Level).reduce(0.0, +) / Double(data.count)
                return (index: dayOffset, label: label, value: avg)
            } else {
                return (index: dayOffset, label: label, value: 0.0)
            }
        }
    }
    
    // Day mode chart data
    private var dayChartData: [(index: Int, hour: Int, value: Double)] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let filtered = allSpO2Records.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
        
        // Group by hour and average
        let groupedByHour = Dictionary(grouping: filtered) { record -> Int in
            calendar.component(.hour, from: record.timestamp)
        }
        
        var result: [(index: Int, hour: Int, value: Double)] = []
        var indexCounter = 0
        
        for hour in 0..<24 {
            if let data = groupedByHour[hour], !data.isEmpty {
                let avg = data.map(\.spO2Level).reduce(0.0, +) / Double(data.count)
                result.append((index: indexCounter, hour: hour, value: avg))
                indexCounter += 1
            }
        }
        
        return result
    }
    
    // Helper function to format hour label
    private func hourLabel(for hour: Int) -> String {
        if hour == 0 {
            return "12 am"
        } else if hour < 12 {
            return "\(hour) am"
        } else if hour == 12 {
            return "12 pm"
        } else {
            return "\(hour - 12) pm"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                    .onTapGesture { unselectChartData() }
                toggleTabs
                    .onTapGesture { unselectChartData() }
                calendarSection
                gaugeSection
                    .onTapGesture { unselectChartData() }
                summarySection
                    .onTapGesture { unselectChartData() }
                timelineChart
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .background(.white)
        .navigationTitle("SpO2 Full Page")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateWeekDates()
        }
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        Text("SpO₂")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primaryColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var toggleTabs: some View {
        HStack(spacing: 8) {
            toggleButton(title: "Day")
            toggleButton(title: "Week")
        }
    }
    
    private func toggleButton(title: String) -> some View {
        Button(title) {
            selectedTab = title
            selectedDataIndex = nil // Reset selection when switching tabs
            if title == "Week" {
                updateWeekDates()
            }
        }
        .font(.headline)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(selectedTab == title ? Color.secondaryColor : .white)
        .foregroundColor(selectedTab == title ? .white : .gray)
        .cornerRadius(8)
        .shadow(color: selectedTab == title ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
    
    private var calendarSection: some View {
        VStack(spacing: 12) {
            // Month navigation buttons
            monthNavigationButtons
            
            // Mode-specific date selectors
            if selectedTab == "Day" {
                daySelector
            } else {
                weekSelector
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
                    .foregroundColor(.primaryColor)
            }
            
            Spacer()
            
            Text(monthYearText)
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                navigateMonth(forward: true)
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryColor)
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
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text("\(day)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primaryColor)
            }
            .frame(width: 50, height: 60)
            .background(isSelected ? Color.secondaryColor : Color.white)
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
                    .foregroundColor(.gray)
                
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
            }
            
            if showingEndDatePicker {
                weekDatePickerView(for: $weekEndDate, isStartDate: false)
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
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(weekDateFormatter.string(from: date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryColor)
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
        VStack {
            DatePicker(
                "",
                selection: binding,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
        }
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
            
            if selectedTab == "Week" {
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
    
    private var gaugeSection: some View {
        SegmentedSpO2Gauge(value: avgSpO2, hasData: hasSpO2Data)
    }

    
    private var summarySection: some View {
        VStack(spacing: 8) {
            Divider()
            HStack {
                summaryItem(
                    title: "Lowest SpO₂",
                    value: hasSpO2Data ? "\(Int(computedLowestSpO2))%" : "No data yet"
                )
                summaryItem(title: "Avg Heart Rate", value: "\(Int(avgHeartRate)) bpm")
            }
            Divider()
        }
    }

    
    private func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.title2)
                .foregroundColor(.primaryColor)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var timelineChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SpO₂ Timeline")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primaryColor)
                .padding(.vertical, 8)
            
            if selectedTab == "Day" {
                dayChart
            } else {
                weekChart
            }
        }
        // Added the white card the chart is on
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private var weekChart: some View {
        Chart {
            // Always show placeholder points to ensure x-axis is visible even with no data
            ForEach(0..<7, id: \.self) { index in
                PointMark(
                    x: .value("Day", index),
                    y: .value("SpO2", 0)
                )
                .foregroundStyle(.clear)
            }
            
            ForEach(weekChartData, id: \.index) { data in
                let isSelected = selectedDataIndex == data.index
                
                // Only show data if value > 0 (has data)
                if data.value > 0 {
                    // Gradient area fill from line to x-axis
                    AreaMark(
                        x: .value("Day", data.index),
                        yStart: .value("SpO2", 0),
                        yEnd: .value("SpO2", data.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 147/255, green: 173/255, blue: 140/255).opacity(0.3),
                                Color(red: 147/255, green: 173/255, blue: 140/255).opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Day", data.index),
                        y: .value("SpO2", data.value)
                    )
                    .foregroundStyle(Color.secondaryColor)
                    .interpolationMethod(.monotone)
                    
                    // Vertical dashed line for the selected point
                    if isSelected {
                        RuleMark(x: .value("Day", data.index))
                            .foregroundStyle(Color.gray)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }
                    
                    PointMark(
                        x: .value("Day", data.index),
                        y: .value("SpO2", data.value)
                    )
                    .foregroundStyle(isSelected ? Color.gray : Color.secondaryColor)
                    .symbolSize(isSelected ? 100 : 60)
                    .annotation(position: .top, alignment: .center, spacing: 4) {
                        if isSelected {
                            chartTooltip(value: data.value)
                        }
                    }
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel(horizontalSpacing: 12)
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
            }
        }
        .chartXAxis {
            AxisMarks(values: [0, 1, 2, 3, 4, 5, 6]) { value in
                if let idx = value.as(Int.self), idx >= 0, idx < weekChartData.count {
                    AxisValueLabel(horizontalSpacing: -5, verticalSpacing: 8) {
                        Text(weekChartData[idx].label)
                            .font(.system(size: 11))
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                }
            }
        }
        .frame(height: 200)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        handleWeekChartTap(at: location, proxy: proxy, geometry: geometry)
                    }
            }
        }
    }
    
    private var dayChart: some View {
        Chart {
            // Always show placeholder points to ensure x-axis is visible even with no data
            ForEach([0, 6, 12, 18], id: \.self) { hour in
                PointMark(
                    x: .value("Hour", hour),
                    y: .value("SpO2", 0)
                )
                .foregroundStyle(.clear)
            }
            
            ForEach(dayChartData, id: \.index) { data in
                let isSelected = selectedDataIndex == data.index
                
                // Gradient area fill from line to x-axis
                AreaMark(
                    x: .value("Hour", data.hour),
                    yStart: .value("SpO2", 0),
                    yEnd: .value("SpO2", data.value)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 147/255, green: 173/255, blue: 140/255).opacity(0.3),
                            Color(red: 147/255, green: 173/255, blue: 140/255).opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Hour", data.hour),
                    y: .value("SpO2", data.value)
                )
                .foregroundStyle(Color.secondaryColor)
                .interpolationMethod(.monotone)
                
                // Vertical dashed line for the selected point
                if isSelected {
                    RuleMark(x: .value("Hour", data.hour))
                        .foregroundStyle(Color.gray)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
                
                PointMark(
                    x: .value("Hour", data.hour),
                    y: .value("SpO2", data.value)
                )
                .foregroundStyle(isSelected ? Color.gray : Color.secondaryColor)
                .symbolSize(isSelected ? 100 : 60)
                .annotation(position: .top, alignment: .center, spacing: 4) {
                    if isSelected {
                        chartTooltip(value: data.value)
                    }
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisValueLabel(horizontalSpacing: 12)
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
            }
        }
        .chartXAxis {
            AxisMarks(values: [0, 4, 8, 12, 16, 20, 24]) { value in
                if let hour = value.as(Int.self) {
                    AxisValueLabel(horizontalSpacing: -5, verticalSpacing: 8){
                        Text(hourLabel(for: hour))
                            .font(.system(size: 12))
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                }
            }
        }
        .chartXScale(domain: 0...23)
        .frame(height: 200)
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
    
    private func chartTooltip(value: Double) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("\(Int(value))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            // Pointing triangle
            SpO2PopoverArrow()
                .fill(Color.white)
                .frame(width: 12, height: 6)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
    }
    
    private func handleWeekChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let plotArea = geometry[plotFrame]
        
        let relativeX = location.x - plotArea.origin.x
        guard relativeX >= 0 && relativeX <= plotArea.width else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedDataIndex = nil }
            return
        }
        
        let data = weekChartData
        let count = max(data.count, 1)
        if count == 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDataIndex = data.first?.value ?? 0 > 0 ? data.first?.index : nil
            }
            return
        }
        
        let normalized = relativeX / plotArea.width
        let rawIndex = normalized * CGFloat(count - 1)
        let tappedPosition = Int(round(rawIndex))
        
        guard tappedPosition >= 0 && tappedPosition < count else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedDataIndex = nil }
            return
        }
        
        let point = data[tappedPosition]
        guard point.value > 0 else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedDataIndex = nil }
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDataIndex = (selectedDataIndex == point.index) ? nil : point.index
        }
    }
    
    private func handleDayChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let plotArea = geometry[plotFrame]
        
        let relativeX = location.x - plotArea.origin.x
        guard relativeX >= 0 && relativeX <= plotArea.width else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedDataIndex = nil }
            return
        }
        
        let data = dayChartData
        let count = max(data.count, 1)
        if count == 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedDataIndex = data.first?.index
            }
            return
        }
        
        let normalized = relativeX / plotArea.width
        let rawIndex = normalized * CGFloat(count - 1)
        let tappedPosition = Int(round(rawIndex))
        
        guard tappedPosition >= 0 && tappedPosition < count else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedDataIndex = nil }
            return
        }
        
        let point = data[tappedPosition]
        
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDataIndex = (selectedDataIndex == point.index) ? nil : point.index
        }
    }
    
    private func unselectChartData() {
        selectedDataIndex = nil
    }

}

struct SegmentedSpO2Gauge: View {
    var value: Double  // 0 to 100
    var hasData: Bool = true  // Whether there's actual data to display
    
    // Initializing segment colors for this SpO2 gauge
    var firstSegmentColor = Color(red: 0.427, green: 0.243, blue: 0.058)
    var secondSegmentColor = Color(red: 0.776, green: 0.525, blue: 0.278)
    var thirdSegmentColor = Color(red: 0.949, green: 0.796, blue: 0.368)
    var fourthSegmentColor = Color.secondaryColor
    
    // 4 segments evenly spaced at 16%, 50%, 84% with gaps
    // The gauge goes from 0 to 0.75 (because 75% of full circle = 270 degrees)
    // So 16% of 0.75 = 0.12, 50% of 0.75 = 0.375, 84% of 0.75 = 0.63
    private let segmentGap: Double = 0.01  // Gap size between segments
    private var segment1End: Double { 0.12 - segmentGap / 2 }  // ~25% of 0.75
    private var segment2Start: Double { 0.12 + segmentGap / 2 }
    private var segment2End: Double { 0.375 - segmentGap / 2 }  // ~50% of 0.75
    private var segment3Start: Double { 0.375 + segmentGap / 2 }
    private var segment3End: Double { 0.63 - segmentGap / 2 }  // ~75% of 0.75
    private var segment4Start: Double { 0.63 + segmentGap / 2 }
    private var segment4End: Double { 0.75 }
    
    // Calculate the position on the gauge for the value
    private var valuePosition: Double {
        let clampedValue = max(0, min(100, value))  // Clamp value to 0-100 range
        let normalizedValue = clampedValue / 100.0  // Normalize 0-100 to 0-1
        return normalizedValue * 0.75  // Map to 0-0.75 range
    }
    
    // Determine which segment color to use based on the value position
    private var indicatorColor: Color {
        if valuePosition <= segment1End {
            return firstSegmentColor
        } else if valuePosition <= segment2End {
            return secondSegmentColor
        } else if valuePosition <= segment3End {
            return thirdSegmentColor
        } else {
            return fourthSegmentColor
        }
    }
    
    var body: some View {
        ZStack {
            // Background colors for the 4 SpO2 gauge segments
            CircleSegment(start: 0.00, end: segment1End, color: firstSegmentColor)
            CircleSegment(start: segment2Start, end: segment2End, color: secondSegmentColor)
            CircleSegment(start: segment3Start, end: segment3End, color: thirdSegmentColor)
            CircleSegment(start: segment4Start, end: segment4End, color: fourthSegmentColor)
            
            // Foreground segments (filled based on value)
            // Only show filled segments if there's data
            if hasData {
                // First segment: fill from 0 to either valuePosition or segment1End, whichever is smaller
                if valuePosition > 0 {
                    let firstSegmentFill = min(segment1End, valuePosition)
                    if firstSegmentFill > 0 {
                        CircleSegment(start: 0.00, end: firstSegmentFill, color: firstSegmentColor)
                    }
                }
                // Second segment: only show if valuePosition has passed segment2Start
                if valuePosition >= segment2Start {
                    let secondSegmentFill = min(segment2End, valuePosition)
                    if secondSegmentFill > segment2Start {
                        CircleSegment(start: segment2Start, end: secondSegmentFill, color: secondSegmentColor)
                    }
                }
                // Third segment: only show if valuePosition has passed segment3Start
                if valuePosition >= segment3Start {
                    let thirdSegmentFill = min(segment3End, valuePosition)
                    if thirdSegmentFill > segment3Start {
                        CircleSegment(start: segment3Start, end: thirdSegmentFill, color: thirdSegmentColor)
                    }
                }
                // Fourth segment: only show if valuePosition has passed segment4Start
                if valuePosition >= segment4Start {
                    let fourthSegmentFill = min(segment4End, valuePosition)
                    if fourthSegmentFill > segment4Start {
                        CircleSegment(start: segment4Start, end: fourthSegmentFill, color: fourthSegmentColor)
                    }
                }
            }
            
            // Circle indicator showing the current SpO2 value position
            // The indicator is positioned at the end of the filled portion of the gauge
            if hasData && valuePosition >= 0 && valuePosition <= 0.75 {
                CircleIndicator(position: valuePosition, color: indicatorColor)
            }
            
            // Center text
            VStack(spacing: 4) {
                if hasData {
                    Text("\(Int(value))%")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryColor)
                    Text("Avg SpO₂")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("No data yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text("Avg SpO₂")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 240, height: 240)
    }
}

struct CircleSegment: View {
    var start: Double
    var end: Double
    var color: Color
    
    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .rotation(Angle(degrees: 135))
            .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .butt))
    }
}

struct CircleIndicator: View {
    var position: Double  // Position on the circle (0 to 0.75)
    var color: Color  // Color based on which segment the value falls into
    
    var body: some View {
        GeometryReader { geometry in
            IndicatorPointShadow(position: position)
                .fill(Color.white)
            IndicatorPointShape(position: position)
                .fill(color)
        }
    }
}

// Circular indicator point correctly positioned along SpO2 gauge
struct IndicatorPointShape: Shape {
    var position: Double  // Position on the gauge (0 to 0.75)
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = 110 + 10  // Outer edge of stroke (center: 110, half width: 10)
        
        // Convert position (0-0.75) to degrees along the arc (0-270°)
        let arcProgress = position / 0.75  // 0 to 1
        let arcDegrees = arcProgress * 270.0  // 0 to 270 degrees
        
        let baseStartAngle = 135.0 // Base rotation of SpO2 gauge
        // Go counterclockwise (opposite to fill) by ADDING arc degrees
        let finalAngle = baseStartAngle + arcDegrees
        
        // Normalize angle to 0-360 range
        let normalizedAngle = finalAngle.truncatingRemainder(dividingBy: 360.0)
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360.0 : normalizedAngle
        
        // Convert to radians for trigonometric functions
        let radians = positiveAngle * .pi / 180.0
        
        // Calculate x,y coordinates on the circle
        let x = center.x + radius * cos(radians)
        let y = center.y + radius * sin(radians)
        
        // Draw a filled circle of radius 26 at this point
        path.addEllipse(in: CGRect(x: x - 13, y: y - 13, width: 26, height: 26))
        return path
    }
}

// White shadow for the circular indicator point on SpO2 gauge
struct IndicatorPointShadow: Shape {
    // Uses same logic for positioning the white shadow as for the circular indicator point in IndicatorPointShape
    var position: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = 110 + 10
        
        let arcProgress = position / 0.75
        let arcDegrees = arcProgress * 270.0
        
        let baseStartAngle = 135.0
        let finalAngle = baseStartAngle + arcDegrees
        
        // Normalize angle to 0-360 range
        let normalizedAngle = finalAngle.truncatingRemainder(dividingBy: 360.0)
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360.0 : normalizedAngle
        
        // Convert to radians for trigonometric functions
        let radians = positiveAngle * .pi / 180.0
        
        // Calculate x,y coordinates on the circle
        let x = center.x + radius * cos(radians)
        let y = center.y + radius * sin(radians)
        
        // Draw a filled circle of radius 30 at this point
        path.addEllipse(in: CGRect(x: x - 15, y: y - 15, width: 30, height: 30))
        return path
    }
}


// MARK: - Popover Arrow Shape
struct SpO2PopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct SpO2View_Previews: PreviewProvider {
    static var previews: some View {
        SpO2View()
    }
}
