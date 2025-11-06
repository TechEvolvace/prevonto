// Blood Pressure page allows user to see and record their blood pressure on a weekly basis.
import SwiftUI
import Charts

// Properties of Blood Pressure data recorded from users
struct BloodPressureRecord: Identifiable {
    let id = UUID()
    let date: Date
    let systolic: Int      // SYS units in mmHg
    let diastolic: Int     // DIA units in mmHg
    let pulse: Int         // Pulse units in BPM
}

// Measurement type for chart display
enum BloodPressureMeasurement: String, CaseIterable {
    case sys = "SYS"
    case dia = "DIA"
    case pulse = "Pulse"
    
    var unit: String {
        switch self {
        case .sys, .dia:
            return "mmHg"
        case .pulse:
            return "BPM"
        }
    }
    
    var chartLabel: String {
        switch self {
        case .sys:
            return "SYS"
        case .dia:
            return "DIA"
        case .pulse:
            return "BrPM"
        }
    }
}

struct BloodPressureView: View {
    @Environment(\.dismiss) private var dismiss
    
    // State for week selection
    @State private var selectedDate: Date = Date()
    @State private var weekStartDate: Date = Date()
    @State private var weekEndDate: Date = Date()
    @State private var showingStartDatePicker: Bool = false
    @State private var showingEndDatePicker: Bool = false
    
    // State for measurement type selection
    @State private var selectedMeasurement: BloodPressureMeasurement = .sys
    @State private var showingMeasurementPicker: Bool = false
    
    // State for chart selection
    @State private var selectedDataIndex: Int? = nil
    
    // State for Add for Today popup
    @State private var showingAddPopup: Bool = false
    @State private var newSystolic: String = ""
    @State private var newDiastolic: String = ""
    @State private var newPulse: String = ""
    
    // Sample Blood Pressure data
    @State private var allRecords: [BloodPressureRecord] = [
        BloodPressureRecord(date: Date.from(year: 2025, month: 5, day: 11), systolic: 118, diastolic: 78, pulse: 72),
        BloodPressureRecord(date: Date.from(year: 2025, month: 5, day: 12), systolic: 122, diastolic: 82, pulse: 75),
        BloodPressureRecord(date: Date.from(year: 2025, month: 5, day: 13), systolic: 120, diastolic: 80, pulse: 70),
        BloodPressureRecord(date: Date.from(year: 2025, month: 5, day: 14), systolic: 125, diastolic: 85, pulse: 78),
        BloodPressureRecord(date: Date.from(year: 2025, month: 5, day: 15), systolic: 119, diastolic: 79, pulse: 74),
        BloodPressureRecord(date: Date.from(year: 2025, month: 5, day: 16), systolic: 128, diastolic: 88, pulse: 96),
        BloodPressureRecord(date: Date.from(year: 2025, month: 5, day: 17), systolic: 121, diastolic: 81, pulse: 73),
        // Additional data for different weeks
        BloodPressureRecord(date: Date.from(year: 2025, month: 8, day: 3), systolic: 120, diastolic: 80, pulse: 72),
        BloodPressureRecord(date: Date.from(year: 2025, month: 8, day: 4), systolic: 118, diastolic: 78, pulse: 70),
        BloodPressureRecord(date: Date.from(year: 2025, month: 8, day: 5), systolic: 122, diastolic: 82, pulse: 74),
        BloodPressureRecord(date: Date.from(year: 2025, month: 8, day: 6), systolic: 125, diastolic: 85, pulse: 76),
        BloodPressureRecord(date: Date.from(year: 2025, month: 8, day: 7), systolic: 119, diastolic: 79, pulse: 71),
        BloodPressureRecord(date: Date.from(year: 2025, month: 8, day: 8), systolic: 123, diastolic: 83, pulse: 96),
        BloodPressureRecord(date: Date.from(year: 2025, month: 8, day: 9), systolic: 121, diastolic: 81, pulse: 73),
    ]
    
    // Chart data for selected week
    private var weeklyChartData: [(index: Int, label: String, value: Int?)] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: weekStartDate)
        
        return (0..<7).map { dayOffset in
            guard let currentDate = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else {
                return (index: dayOffset, label: "", value: nil as Int?)
            }
            
            let weekdayIndex = calendar.component(.weekday, from: currentDate) - 1
            let label = calendar.shortWeekdaySymbols[weekdayIndex]
            
            // Find record for this date
            let record = allRecords.first { calendar.isDate($0.date, inSameDayAs: currentDate) }
            
            let value: Int?
            if let record = record {
                switch selectedMeasurement {
                case .sys:
                    value = record.systolic
                case .dia:
                    value = record.diastolic
                case .pulse:
                    value = record.pulse
                }
            } else {
                value = nil
            }
            
            return (index: dayOffset, label: label, value: value)
        }
    }
    
    // Weekly averages
    private var weeklyAverageSystolic: Int {
        let weekData = getWeekRecords()
        guard !weekData.isEmpty else { return 0 }
        return weekData.reduce(0) { $0 + $1.systolic } / weekData.count
    }
    
    private var weeklyAverageDiastolic: Int {
        let weekData = getWeekRecords()
        guard !weekData.isEmpty else { return 0 }
        return weekData.reduce(0) { $0 + $1.diastolic } / weekData.count
    }
    
    private var weeklyAveragePulse: Int {
        let weekData = getWeekRecords()
        guard !weekData.isEmpty else { return 0 }
        return weekData.reduce(0) { $0 + $1.pulse } / weekData.count
    }
    
    private func getWeekRecords() -> [BloodPressureRecord] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: weekStartDate)
        let endOfWeek = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 7, to: startOfWeek)!)
        
        return allRecords.filter { $0.date >= startOfWeek && $0.date < endOfWeek }
    }
    
    private var hasWeeklyData: Bool {
        !getWeekRecords().isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Section
                        headerSection
                        
                        // Current BP + Add Button
                        currentBPSection
                        
                        // Weekly Average Card (only show if there's data)
                        if hasWeeklyData {
                            weeklyAverageCard
                                .onTapGesture { unselectChartData() }
                        }
                        
                        // Date Navigation
                        dateNavigationSection
                        
                        // Measurement Selector
                        measurementSelector
                        
                        // Chart Section
                        chartSection
                        
                        // Trends Section
                        trendsSection
                            .onTapGesture { unselectChartData() }
                        
                        // Insights Section
                        insightsSection
                            .onTapGesture { unselectChartData() }
                    }
                    .padding(.horizontal, 15)
                }
                .background(Color.white)
                
                // Add for Today Popup Overlay
                if showingAddPopup {
                    addForTodayPopup
                }
            }
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
            Text("Blood pressure")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryGreen)
            
            Text("Your blood pressure must be recorded by you on a weekly basis.")
                .font(.subheadline)
                .foregroundColor(.grayText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .onTapGesture { unselectChartData() }
    }
    
    // MARK: - Current BP Section
    private var currentBPSection: some View {
        HStack {
            Text("Current BP")
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            Spacer()
            
            Button(action: {
                // Reset fields
                newSystolic = ""
                newDiastolic = ""
                newPulse = ""
                showingAddPopup = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add for Today")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.primaryGreen)
                .cornerRadius(20)
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Weekly Average Card
    private var weeklyAverageCard: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(weeklyAverageSystolic)/\(weeklyAverageDiastolic)")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundColor(.primaryGreen)
                Text(" mmHg")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.primaryGreen)
            }
            
            Text("Weekly Average")
                .font(.custom("Noto Sans", size: 16))
                .foregroundColor(.grayText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 8)
    }
    
    // MARK: - Date Navigation Section
    private var dateNavigationSection: some View {
        VStack(spacing: 12) {
            // Month navigation
            monthNavigationButtons
            
            // Week selector
            weekSelector
        }
    }
    
    private var monthNavigationButtons: some View {
        HStack {
            Button(action: { navigateMonth(forward: false) }) {
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
            
            Button(action: { navigateMonth(forward: true) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
    }
    
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
                            if showingStartDatePicker { showingEndDatePicker = false }
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
                            if showingEndDatePicker { showingStartDatePicker = false }
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
            selectedDate = weekStartDate
        }
    }
    
    private func dismissEndDatePicker() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            let calendar = Calendar.current
            if let newStartDate = calendar.date(byAdding: .day, value: -6, to: weekEndDate) {
                weekStartDate = newStartDate
            }
            showingEndDatePicker = false
            selectedDate = weekStartDate
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
        .onChange(of: binding.wrappedValue) { newDate in
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
            selectedDate = weekStartDate
        }
    }
    
    // MARK: - Measurement Selector
    private var measurementSelector: some View {
        HStack {
            Menu {
                ForEach(BloodPressureMeasurement.allCases, id: \.self) { measurement in
                    Button(action: {
                        selectedMeasurement = measurement
                        selectedDataIndex = nil
                    }) {
                        Text(measurement.rawValue)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedMeasurement.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.grayText)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.grayText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedMeasurement.chartLabel)
                .foregroundColor(.grayText)
                .font(.headline)
            
            bloodPressureChart
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.bottom, 16)
    }
    
    private var bloodPressureChart: some View {
        Chart {
            // Placeholder points to ensure x-axis is visible
            ForEach(0..<7, id: \.self) { idx in
                PointMark(x: .value("Day", idx), y: .value("Value", 0))
                    .foregroundStyle(.clear)
            }
            
            // Actual data
            ForEach(weeklyChartData.filter { $0.value != nil }, id: \.index) { data in
                LineMark(
                    x: .value("Day", data.index),
                    y: .value("Value", data.value!)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.bpLineBlue)
                
                PointMark(
                    x: .value("Day", data.index),
                    y: .value("Value", data.value!)
                )
                .foregroundStyle(selectedDataIndex == data.index ? Color.selectionGreen : Color.primaryGreen)
                .symbolSize(selectedDataIndex == data.index ? 100 : 60)
                .annotation(position: .top, alignment: .center, spacing: 4) {
                    if selectedDataIndex == data.index {
                        chartTooltip(value: data.value!)
                    }
                }
            }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: Array(0..<7)) { value in
                if let idx = value.as(Int.self), idx < weeklyChartData.count {
                    AxisValueLabel {
                        Text(weeklyChartData[idx].label)
                            .font(.system(size: 11))
                    }
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXScale(domain: 0...6)
        .chartYScale(domain: 0...220)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        handleChartTap(at: location, geometry: geometry)
                    }
            }
        }
    }
    
    private func chartTooltip(value: Int) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("\(value)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryGreen)
                Text(selectedMeasurement.chartLabel)
                    .font(.system(size: 10))
                    .foregroundColor(.grayText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            // Pointing triangle
            BPPopoverArrow()
                .fill(Color.white)
                .frame(width: 12, height: 6)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
    }
    
    private func handleChartTap(at location: CGPoint, geometry: GeometryProxy) {
        let chartWidth = geometry.size.width
        let barWidth = chartWidth / 7
        let tappedIndex = Int(location.x / barWidth)
        
        guard tappedIndex >= 0 && tappedIndex < 7 else {
            selectedDataIndex = nil
            return
        }
        
        if selectedDataIndex == tappedIndex {
            selectedDataIndex = nil
        } else {
            // Check if there's data at this index
            if weeklyChartData[tappedIndex].value != nil {
                selectedDataIndex = tappedIndex
            }
        }
    }
    
    private func unselectChartData() {
        selectedDataIndex = nil
    }
    
    // MARK: - Trends Section
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            // Trend summary
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 24))
                    .foregroundColor(.primaryGreen)
                    .frame(width: 40, height: 40)
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(20)
                
                Text("Higher \(selectedMeasurement.chartLabel) by 25% this week as compared to your average metrics")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(.grayText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 8)
            
            // Trends Chart
            trendsChart
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
    }
    
    private var trendsChart: some View {
        Chart {
            // Current line
            ForEach(weeklyChartData.filter { $0.value != nil }, id: \.index) { data in
                LineMark(
                    x: .value("Day", data.index),
                    y: .value("Current", data.value!),
                    series: .value("Type", "Current")
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.primaryGreen)
            }
            
            // Average line
            ForEach(0..<7, id: \.self) { idx in
                LineMark(
                    x: .value("Day", idx),
                    y: .value("Avg", averageValue),
                    series: .value("Type", "Avg")
                )
                .foregroundStyle(Color.grayText.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 2]))
            }
        }
        .frame(height: 150)
        .chartXAxis {
            AxisMarks(values: Array(0..<7)) { value in
                if let idx = value.as(Int.self), idx < weeklyChartData.count {
                    AxisValueLabel {
                        Text(weeklyChartData[idx].label)
                            .font(.system(size: 10))
                    }
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartYScale(domain: 0...220)
        .chartForegroundStyleScale([
            "Current": Color.primaryGreen,
            "Avg": Color.grayText.opacity(0.5)
        ])
        .chartLegend(position: .top, alignment: .trailing)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var averageValue: Int {
        switch selectedMeasurement {
        case .sys:
            return weeklyAverageSystolic > 0 ? weeklyAverageSystolic - 10 : 110
        case .dia:
            return weeklyAverageDiastolic > 0 ? weeklyAverageDiastolic - 5 : 75
        case .pulse:
            return weeklyAveragePulse > 0 ? weeklyAveragePulse - 8 : 70
        }
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
                    BPInsightRow(number: 1, text: "Try to complete one Breath Training every day", isLast: false)
                    BPInsightRow(number: 2, text: "Your blood pressure is within healthy range", isLast: true)
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
        weeklyChartData.contains { $0.value != nil }
    }
    
    // MARK: - Add for Today Popup
    private var addForTodayPopup: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    showingAddPopup = false
                }
            
            // Popup content
            VStack(spacing: 20) {
                // Header with date and clear button
                HStack {
                    Text(todayDateString)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.grayText)
                    
                    Spacer()
                    
                    Button(action: {
                        newSystolic = ""
                        newDiastolic = ""
                        newPulse = ""
                    }) {
                        Text("Clear")
                            .font(.system(size: 14))
                            .foregroundColor(.grayText)
                    }
                }
                
                // Input fields
                VStack(spacing: 16) {
                    inputField(label: "SYS", unit: "mmHg", value: $newSystolic)
                    inputField(label: "DIA", unit: "mmHg", value: $newDiastolic)
                    inputField(label: "Pulse", unit: "BPM", value: $newPulse)
                }
                
                // Save button
                Button(action: saveNewReading) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.secondaryGreen)
                        .cornerRadius(10)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
    }
    
    private func inputField(label: String, unit: String, value: Binding<String>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryGreen)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.grayText)
            }
            
            Spacer()
            
            TextField("", text: value)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primaryGreen)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .frame(width: 80)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.grayText.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        return formatter.string(from: Date())
    }
    
    private func saveNewReading() {
        guard let sys = Int(newSystolic),
              let dia = Int(newDiastolic),
              let pulse = Int(newPulse) else {
            return
        }
        
        let newRecord = BloodPressureRecord(
            date: Date(),
            systolic: sys,
            diastolic: dia,
            pulse: pulse
        )
        
        allRecords.append(newRecord)
        showingAddPopup = false
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
            updateWeekDates()
        }
    }
    
    private func updateWeekDates() {
        let calendar = Calendar.current
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) {
            weekStartDate = weekInterval.start
            weekEndDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
        }
    }
}

// MARK: - Colors
private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)
    static let grayText = Color(red: 0.25, green: 0.33, blue: 0.44)
    static let selectionGreen = Color(red: 96/255, green: 142/255, blue: 97/255)
    static let bpLineBlue = Color.blue.opacity(0.7)
}

// MARK: - Popover Arrow Shape
struct BPPopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Insight Row Component
struct BPInsightRow: View {
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
    BloodPressureView()
}
