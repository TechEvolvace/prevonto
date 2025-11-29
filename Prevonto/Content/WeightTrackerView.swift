// Weight Tracker page shows the user's weight across week or month.
import Foundation
import SwiftUI
import Charts

private struct WeightChartPoint: Identifiable {
    let id = UUID()
    let index: Int
    let label: String
    let date: Date
    let valueLb: Double?
}


class WeightTrackerManager: ObservableObject {
    @Published var entries: [WeightEntry] = []
    private var repository: WeightRepository

    init(repository: WeightRepository = LocalWeightRepository()) {
        self.repository = repository
        self.entries = repository.fetchEntries()
    }

    var averageWeightLb: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { $0.weightLb }.reduce(0, +) / Double(entries.count)
    }
    
    // Calculate average for a specific date range, using only the most recent entry per day
    func averageWeightLb(for startDate: Date, endDate: Date, calendar: Calendar) -> Double {
        // Filter entries by date range
        let filtered = entries.filter { entry in
            let entryDate = calendar.startOfDay(for: entry.date)
            let start = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate)
            return entryDate >= start && entryDate <= end
        }
        guard !filtered.isEmpty else { return 0 }
        
        // Group entries by day and take the most recent entry for each day
        var entriesByDay: [Date: WeightEntry] = [:]
        for entry in filtered {
            let dayStart = calendar.startOfDay(for: entry.date)
            // If no entry for this day yet, or this entry is more recent, use this one
            if let existingEntry = entriesByDay[dayStart] {
                if entry.date > existingEntry.date {
                    entriesByDay[dayStart] = entry
                }
            } else {
                entriesByDay[dayStart] = entry
            }
        }
        
        // Calculate average from most recent entry per day
        let uniqueEntries = Array(entriesByDay.values)
        guard !uniqueEntries.isEmpty else { return 0 }
        return uniqueEntries.map { $0.weightLb }.reduce(0, +) / Double(uniqueEntries.count)
    }

    func addEntry(weight: Double) {
        repository.addEntry(weight: weight)
        entries = repository.fetchEntries()
    }
}



// MARK: - WeightTrackerView
struct WeightTrackerView: View {
    @State private var selectedUnit: String = "Lbs"
    @State private var selectedTab: String = "Week"
    @State private var inputWeight: String = ""
    @ObservedObject private var manager = WeightTrackerManager()
    @State private var selectedChartIndex: Int? = nil
    @State private var isLoggedEntriesExpanded: Bool = false
    
    // State for popup
    @State private var showingAddPopup: Bool = false
    @State private var popupSelectedUnit: String = "Lbs"
    @State private var popupSelectedWeight: Int = 0


    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    inputSection
                    averageSection
                    weekMonthToggle
                    weightsChartSection
                    trendsSection
                    loggedEntriesSection
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .background(Color.white)
            .navigationTitle("Weight Full Page")
            .navigationBarTitleDisplayMode(.inline)
            
            // Add for Today Popup Overlay
            if showingAddPopup {
                addForTodayPopup
            }
        }
    }

    // Weight Tracker page header
    private var headerSection: some View {
        VStack(spacing: 4){
            Text("Weight Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.primaryGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Your weight will need to be recorded manually by you on a daily/weekly basis.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.darkGrayText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
        }
    }

    private var inputSection: some View {
        HStack {
            Text("Current Weight")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryGreen)
            
            Spacer()
            
            Button(action: {
                // Reset to default values
                popupSelectedUnit = "Lbs"
                popupSelectedWeight = 0
                showingAddPopup = true
            }) {
                HStack(spacing: 2) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16, weight: .regular))
                    Text("Add for Today")
                        .font(.system(size: 16, weight: .regular))
                }
                .foregroundColor(Color.primaryGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.15)
        )
        .padding(.bottom, 8)
    }

    // Displaying the weekly average or monthly averages
    private var averageSection: some View {
        // Calculate average based on selected period
        let avg: Double
        let hasData = !manager.entries.isEmpty
        if selectedTab == "Week" {
            let weekStart = currentWeekStart
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? Date()
            avg = manager.averageWeightLb(for: weekStart, endDate: weekEnd, calendar: calendar)
        } else {
            // Month mode
            let today = Date()
            if let monthInterval = calendar.dateInterval(of: .month, for: today),
               let monthEnd = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) {
                avg = manager.averageWeightLb(for: monthInterval.start, endDate: monthEnd, calendar: calendar)
            } else {
                avg = 0
            }
        }
        let displayWeight = selectedUnit == "Kg" ? avg * 0.453592 : avg

        return VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 0) {
                if hasData {
                    HStack(spacing: 6){
                        Text("\(String(format: "%.1f", displayWeight))")
                            .font(.system(size: 48, weight:  .bold))
                            .foregroundColor(Color.secondaryGreen)
                        
                        Text("\(selectedUnit.lowercased()).")
                            .font(.system(size: 36, weight:  .semibold))
                            .foregroundColor(Color.gray.opacity(0.8))
                            .padding(.top, 8)
                    }
                } else {
                    Text("No data yet")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(Color.darkGrayText)
                }
                
                Text("\(selectedTab)ly Average")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.gray)
                
                Spacer()
                    .frame(height: 16)

                unitToggle
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 0.15)
            }
        }
    }
    
    // Buttons to toggle between lbs and kg units for weights
    private var unitToggle: some View {
        HStack(spacing: 0) {
            Button(action: { selectedUnit = "Lbs" }) {
                Text("Lb")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(selectedUnit == "Lbs" ? Color.secondaryGreen : Color.gray.opacity(0.2))
                    .foregroundColor(selectedUnit == "Lbs" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 8,
                bottomLeadingRadius: 8,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            ))

            Button(action: { selectedUnit = "Kg" }) {
                Text("Kg")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(selectedUnit == "Kg" ? Color.secondaryGreen : Color.gray.opacity(0.2))
                    .foregroundColor(selectedUnit == "Kg" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 8,
                topTrailingRadius: 8
            ))
        }
    }

    // Buttons to toggle between Week mode or Month mode
    private var weekMonthToggle: some View {
        HStack {
            Button("Week") {
                selectedTab = "Week"
                selectedChartIndex = nil
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(selectedTab == "Week" ? Color.secondaryGreen : Color.white)
            .foregroundColor(selectedTab == "Week" ? .white : Color.gray)
            .cornerRadius(8)
            .shadow(color: selectedTab == "Week" ? .clear : Color.neutralShadow, radius: 4, x: 0, y: 4)

            Button("Month") {
                selectedTab = "Month"
                selectedChartIndex = nil
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(selectedTab == "Month" ? Color.secondaryGreen : Color.white)
            .foregroundColor(selectedTab == "Month" ? .white : Color.gray)
            .cornerRadius(8)
            .shadow(color: selectedTab == "Month" ? .clear : Color.neutralShadow, radius: 4, x: 0, y: 4)
        }
    }

    private var weightsChartSection: some View {
        let data = selectedTab == "Week" ? weekChartData : monthChartData
        let yDomain = weightYDomain(for: data)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Weight (\(selectedUnit.lowercased()))")
                .foregroundColor(.gray)
                .font(.headline)
            
            Chart {
                // Placeholder points to keep consistent x-axis spacing
                ForEach(0..<data.count, id: \.self) { idx in
                    PointMark(x: .value("Index", idx), y: .value("Weight", 0))
                        .foregroundStyle(.clear)
                }
                
                // Actual data line and dots
                ForEach(data.filter { $0.valueLb != nil }, id: \.id) { point in
                    let converted = displayWeight(point.valueLb!)
                    
                    LineMark(
                        x: .value("Index", point.index),
                        y: .value("Weight", converted)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.primaryGreen)
                    
                    PointMark(
                        x: .value("Index", point.index),
                        y: .value("Weight", converted)
                    )
                    .foregroundStyle(selectedChartIndex == point.index ? Color.selectionGreen : Color.primaryGreen)
                    .symbolSize(selectedChartIndex == point.index ? 100 : 60)
                    .annotation(position: .top, alignment: .center, spacing: 4) {
                        if selectedChartIndex == point.index {
                            weightTooltip(for: point)
                        }
                    }
                }
            }
            .frame(height: 220)
            .chartXAxis {
                if selectedTab == "Week" {
                    AxisMarks(values: Array(0..<7)) { value in
                        if let idx = value.as(Int.self), idx < data.count {
                            AxisValueLabel(horizontalSpacing: -5, verticalSpacing: 16) {
                                Text(data[idx].label)
                                    .font(.system(size: 12))
                            }
                            AxisTick(length: 12, stroke: StrokeStyle(lineWidth: 0.3))
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                        }
                    }
                } else {
                    AxisMarks(values: data.map { $0.index }) { value in
                        if let idx = value.as(Int.self), idx < data.count {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                            
                            let label = data[idx].label
                            if ["1", "7", "14", "21", "28"].contains(label) {
                                AxisValueLabel(verticalSpacing: 12) {
                                    Text(label)
                                        .font(.system(size: 12))
                                }
                                AxisTick(length: 12, stroke: StrokeStyle(lineWidth: 0.3))
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                    AxisValueLabel(horizontalSpacing: 16)
                }
            }
            .chartXScale(domain: 0...Double(max(data.count - 1, 0)))
            .chartYScale(domain: yDomain)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            handleChartTap(at: location, proxy: proxy, geometry: geometry, data: data)
                        }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
    }

    // Display trends information from weight data
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trends")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.gray)

            HStack{
                VStack {
                    Text("Stable")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(width: 60)
                .padding(.vertical, 8)
                .foregroundStyle(Color.white)
                .background(Color.secondaryGreen)
                .cornerRadius(8)
                
                Text("No significant change in weight today—great consistency!")
                    .font(.footnote)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 0.15)
            )

            HStack {
                VStack {
                    Text("BMI")
                        .font(.system(size: 16, weight: .semibold))
                    Text("22")
                        .font(.system(size: 22, weight: .bold))
                }
                .frame(width: 60)
                .padding(.vertical, 8)
                .foregroundStyle(Color.white)
                .background(Color.yellow)
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("This BMI falls outside the typical range. Tracking your health over time can offer helpful insight.")
                        .font(.footnote)
                    Text("Learn more...")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 0.15)
            )
        }
    }

    // Logged Entries dropdown button to display recent added weight entries
    private var loggedEntriesSection: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoggedEntriesExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Logged Entries")
                        .font(.headline)
                        .foregroundColor(Color.primaryGreen)
                    Spacer()
                    Image(systemName: isLoggedEntriesExpanded ? "chevron.down" : "chevron.left")
                        .foregroundColor(Color.primaryGreen)
                }
            }
            .buttonStyle(PlainButtonStyle())

            if isLoggedEntriesExpanded {
                ForEach(manager.entries) { entry in
                    HStack {
                        Text(entry.formattedDate)
                            .foregroundStyle(Color.gray)
                        Spacer()
                        Text(String(format: "%.1f", entry.weight(in: selectedUnit)))
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.vertical, 4)
                    Divider()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.15)
        )
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
            VStack(spacing: 0) {
                // Lb/Kg toggle buttons
                popupUnitToggle
                    .padding(.bottom, 20)
                
                // Display weight amount in current unit
                HStack(spacing: 8) {
                    Text("\(popupSelectedWeight)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color.secondaryGreen)
                    Text(popupSelectedUnit.lowercased())
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                        .offset(y: 8)
                }
                .padding(.bottom, 8)
                
                // Weight picker
                WeightPickerView(
                    values: popupSelectedUnit == "Lbs" ? Array(0...500) : Array(0...227),
                    selected: $popupSelectedWeight,
                    unit: popupSelectedUnit
                )
                .frame(height: 320)
                .padding(.bottom, -200)
                
                // Save button
                Button(action: saveNewWeight) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primaryGreen)
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
    
    private var popupUnitToggle: some View {
        HStack(spacing: 0) {
            Button(action: {
                if popupSelectedUnit != "Lbs" {
                    let converted = Int(Double(popupSelectedWeight) * 2.205)
                    popupSelectedWeight = min(max(converted, 0), 500)
                    popupSelectedUnit = "Lbs"
                }
            }) {
                Text("Lb")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(popupSelectedUnit == "Lbs" ? Color.secondaryGreen : Color.gray.opacity(0.2))
                    .foregroundColor(popupSelectedUnit == "Lbs" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 8,
                bottomLeadingRadius: 8,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            ))
            
            Button(action: {
                if popupSelectedUnit != "Kg" {
                    let converted = Int(Double(popupSelectedWeight) * 0.45359237)
                    popupSelectedWeight = min(max(converted, 0), 227)
                    popupSelectedUnit = "Kg"
                }
            }) {
                Text("Kg")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(popupSelectedUnit == "Kg" ? Color.secondaryGreen : Color.gray.opacity(0.2))
                    .foregroundColor(popupSelectedUnit == "Kg" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 8,
                topTrailingRadius: 8
            ))
        }
    }
    
    private func saveNewWeight() {
        // Convert to lbs for storage (since WeightEntry stores in lbs)
        let weightInLbs: Double
        if popupSelectedUnit == "Kg" {
            weightInLbs = Double(popupSelectedWeight) * 2.205
        } else {
            weightInLbs = Double(popupSelectedWeight)
        }
        
        manager.addEntry(weight: weightInLbs)
        showingAddPopup = false
    }
    
    // MARK: - Chart Helpers
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 1 // Sunday start
        return cal
    }
    
    private var currentWeekStart: Date {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let start = calendar.date(byAdding: .day, value: -(weekday - 1), to: calendar.startOfDay(for: today)) ?? today
        return start
    }
    
    // Helper to get the most recent weight for a specific date from user entries
    private func getWeightForDate(_ date: Date) -> Double? {
        // Get all entries for this date, sorted by time (most recent first)
        let entriesForDate = manager.entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date > $1.date } // Most recent first
        
        // Return the most recent entry's weight
        return entriesForDate.first?.weightLb
    }
    
    private var weekChartData: [WeightChartPoint] {
        (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: currentWeekStart) ?? Date()
            let label = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let weightLb = getWeightForDate(date)
            return WeightChartPoint(index: offset, label: label, date: date, valueLb: weightLb)
        }
    }
    
    private var monthChartData: [WeightChartPoint] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()),
              let dayRange = calendar.range(of: .day, in: .month, for: Date()) else {
            return []
        }
        
        return dayRange.map { day in
            let date = calendar.date(bySetting: .day, value: day, of: monthInterval.start) ?? Date()
            let weightLb = getWeightForDate(date)
            return WeightChartPoint(index: day - 1, label: "\(day)", date: date, valueLb: weightLb)
        }
    }
    
    private func displayWeight(_ weightLb: Double) -> Double {
        selectedUnit == "Kg" ? weightLb * 0.453592 : weightLb
    }
    
    private func weightTooltip(for point: WeightChartPoint) -> some View {
        let value = displayWeight(point.valueLb ?? 0)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(formatter.string(from: point.date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Text(String(format: "%.1f", value))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryGreen)
                Text(selectedUnit.lowercased())
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
            
            BPPopoverArrow()
                .fill(Color.white)
                .frame(width: 12, height: 6)
                .shadow(color: Color.neutralShadow, radius: 1, x: 0, y: 1)
        }
    }
    
    private func weightYDomain(for data: [WeightChartPoint]) -> ClosedRange<Double> {
        let values = data.compactMap { $0.valueLb }.map(displayWeight)
        guard let minVal = values.min(), let maxVal = values.max() else {
            return 0...1
        }
        
        let padding = 5.0
        let lower = max(0, floor((minVal - padding) / 5) * 5)
        let upper = ceil((maxVal + padding) / 5) * 5
        return lower...max(upper, lower + 5)
    }
    
    private func handleChartTap(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy, data: [WeightChartPoint]) {
        guard let plotFrame = proxy.plotFrame else { return }
        let plotArea = geometry[plotFrame]
        
        let relativeX = location.x - plotArea.origin.x
        guard relativeX >= 0 && relativeX <= plotArea.width else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedChartIndex = nil }
            return
        }
        
        let count = max(data.count, 1)
        if count == 1 {
            withAnimation(.easeInOut(duration: 0.2)) { selectedChartIndex = data.first?.valueLb != nil ? 0 : nil }
            return
        }
        
        let normalized = relativeX / plotArea.width
        let rawIndex = normalized * CGFloat(count - 1)
        let tappedIndex = Int(round(rawIndex))
        
        guard tappedIndex >= 0 && tappedIndex < data.count else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedChartIndex = nil }
            return
        }
        
        guard data[tappedIndex].valueLb != nil else {
            withAnimation(.easeInOut(duration: 0.2)) { selectedChartIndex = nil }
            return
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedChartIndex = (selectedChartIndex == tappedIndex) ? nil : tappedIndex
        }
    }
}

// MARK: Some custom-defined colors
private extension Color {
    static let barDefault = Color(red: 0.682, green: 0.698, blue: 0.788)
    static let selectionGreen = Color(red: 96/255, green: 142/255, blue: 97/255)
}

// To preview Weight Tracker page, for only developer uses
struct WeightTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        WeightTrackerView()
    }
}
