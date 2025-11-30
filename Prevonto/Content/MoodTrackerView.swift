// Mood Tracker page displays user's mood across week or month.
import SwiftUI
import Charts

struct MoodLogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let mood: MoodType
    let energy: Int
}

enum MoodType: String, CaseIterable {
    case depressed = "Depressed"
    case sad = "Sad"
    case neutral = "Neutral"
    case happy = "Happy"
    case veryHappy = "Overjoyed"

    var color: Color {
        switch self {
        case .depressed: return Color.depressedColor
        case .sad: return Color.sadColor
        case .neutral: return Color.neutralColor
        case .happy: return Color.happyColor
        case .veryHappy: return Color.overjoyedColor
        }
    }
}

// Custom segmented progress bar for the popup
struct PopupProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    let segmentSpacing: CGFloat = 8
    
    var body: some View {
        HStack(spacing: segmentSpacing) {
            ForEach(1...totalSteps, id: \.self) { step in
                Rectangle()
                    .fill(step <= currentStep ? Color.primaryGreen : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
    }
}

// Mood Entry Card - the first part of the popup that shows up when the user clicks on the Log energy levels button
struct MoodEntryCard: View {
    @Binding var show: Bool
    var onNext: (MoodType) -> Void
    @State private var selectedMood = MoodType.neutral

    private func emotionIconName(for mood: MoodType) -> String {
        switch mood {
        case .depressed: return "Emotion depressed"
        case .sad: return "Emotion sad"
        case .neutral: return "Emotion neutral"
        case .happy: return "Emotion happy"
        case .veryHappy: return "Emotion overjoyed"
        }
    }

    var body: some View {
        ZStack {
            // Enable to exit out the popup by touching anywhere outside the popup
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    show = false
                }

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        // Date
                        Text(Date(), style: .date)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Clear button exits out the popup
                        Button("Clear") {
                            selectedMood = .neutral
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    }
                    
                    // Horizontal segmented progress bar for popup
                    PopupProgressBar(currentStep: 1, totalSteps: 2)

                    Text("1 of 2")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)

                    Text("How are you feeling \ntoday?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding()

                // Vertical selection of emotion icon buttons
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(MoodType.allCases.enumerated()), id: \.element) { index, mood in
                            Button(action: {
                                selectedMood = mood
                            }) {
                                let isNeutral = mood == .neutral
                                let isSelected = selectedMood == mood
                                let baseIconSize: CGFloat = isSelected ? 80 : 60
                                let iconName = emotionIconName(for: mood)
                                
                                Image(iconName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(mood.color)
                                    .background(.clear)
                                    .aspectRatio(contentMode: .fit)
                                    .scaleEffect(isNeutral ? 2.6 : 1.0, anchor: .center)
                                    .frame(width: baseIconSize, height: baseIconSize)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(height: 350)

                Text("I'm feeling \(selectedMood.rawValue.lowercased()).")
                    .font(.system(size: 24, weight: .medium))

                // Clicking on the Next button here takes the user to the second part of the popup: the Energy Entry Card
                Button("Next") {
                    onNext(selectedMood)
                    show = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primaryGreen)
                .font(.headline)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 30)
        }
    }
}

// Energy Entry Card - the second part of the popup
struct EnergyEntryCard: View {
    @Binding var show: Bool
    var onSave: (Int) -> Void
    @State private var selectedEnergy = 7

    let energyRange = Array(0...10)

    var body: some View {
        ZStack {
            // Enable to exit out the popup by touching anywhere outside the popup
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    show = false
                }

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8){
                    HStack {
                        // Date
                        Text(Date(), style: .date)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Clear button exits out the popup
                        Button("Clear") {
                            selectedEnergy = 7
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    }
                    
                    // Horizontal segmented progress bar for popup
                    PopupProgressBar(currentStep: 2, totalSteps: 2)

                    Text("2 of 2")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)

                    Text("What would you rate \nyour energy levels?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding()

                // Picker for user to swipe or drag vertically to specific energy level user chooses
                CenteredVerticalEnergyPicker(energyLevels: energyRange, selectedEnergy: $selectedEnergy)
                    .frame(height: 350)

                Text("\(selectedEnergy)/10")
                    .font(.system(size: 24, weight: .medium))

                // Save button when clicked will log a new recorded energy level for today
                Button("Save") {
                    onSave(selectedEnergy)
                    show = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primaryGreen)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 30)
        }
    }
}

// Picker for user to swipe or drag vertically to specific energy level user chooses
struct CenteredVerticalEnergyPicker: View {
    let energyLevels: [Int]
    @Binding var selectedEnergy: Int

    let itemHeight: CGFloat = 80
    let spacing: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let totalHeight = itemHeight + spacing
            let centerY = geo.frame(in: .global).midY

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: spacing) {
                        ForEach(energyLevels, id: \.self) { energy in
                            EnergyRow(energy: energy,
                                     selectedEnergy: $selectedEnergy,
                                     centerY: centerY,
                                     itemHeight: itemHeight,
                                     totalHeight: totalHeight)
                                .id(energy)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, (geo.size.height - itemHeight) / 2)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(selectedEnergy, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// Display each energy level number for user to select
struct EnergyRow: View {
    let energy: Int
    @Binding var selectedEnergy: Int
    let centerY: CGFloat
    let itemHeight: CGFloat
    let totalHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
            let itemCenterY = geo.frame(in: .global).midY
            let distance = abs(itemCenterY - centerY)
            let maxDistance: CGFloat = totalHeight * 2.5 // Distance for full fade
            let normalizedDistance = min(distance / maxDistance, 1.0)
            
            // Determine if this is the selected energy level
            let isSelected = distance < totalHeight / 2
            
            // Dynamic font size based on distance from center, decreasing smoothly as distance increases
            let fontSize: CGFloat = {
                if isSelected {
                    return 52
                } else {
                    // Using normalizedDistance for smooth transition
                    let minSize: CGFloat = 24
                    let maxSize: CGFloat = 52
                    return maxSize - (normalizedDistance * (maxSize - minSize))
                }
            }()
            
            // Dynamic opacity based on distance
            let opacity = isSelected ? 1.0 : max(0.3, 1.0 - normalizedDistance * 0.7)
            
            // Calculate box width based on number of digits
            let boxWidth: CGFloat = isSelected ? 140 : 0

            Text("\(energy)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(isSelected ? .white : .gray.opacity(opacity))
                .frame(width: isSelected ? boxWidth : nil, height: itemHeight)
                .background(
                    isSelected ? Color.secondaryGreen : Color.clear
                )
                .cornerRadius(isSelected ? 16 : 0)
                .shadow(color: isSelected ? Color.green.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                .frame(maxWidth: .infinity)
                .onAppear {
                    if isSelected {
                        selectedEnergy = energy
                    }
                }
                .onChange(of: distance) {
                    if isSelected {
                        selectedEnergy = energy
                    }
                }
        }
        .frame(height: itemHeight)
    }
}



struct MoodTrackerView: View {
    @State private var selectedTab = "Month"
    @State private var entries: [MoodLogEntry] = [
        MoodLogEntry(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, mood: .sad, energy: 4),
        MoodLogEntry(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, mood: .happy, energy: 7),
        MoodLogEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, mood: .neutral, energy: 5)
    ]
    @State private var showMoodEntry = false
    @State private var showEnergyEntry = false
    @State private var tempMood: MoodType? = nil
    @State private var selectedBarIndex: Int? = nil
    @State private var currentDate = Date()

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    logButton
                    moodTrackerSummary
                    toggleTabs
                    calendarSection
                    energyChart
                        .padding(.bottom, 20)
                    insightSection
                }
                .padding(.horizontal, 16)
            }
            .background(Color.white)
            .navigationTitle("Mood Tracker")
            .navigationBarTitleDisplayMode(.inline)

            if showMoodEntry {
                MoodEntryCard(show: $showMoodEntry) { mood in
                    tempMood = mood
                    showEnergyEntry = true
                }
            }

            if showEnergyEntry {
                EnergyEntryCard(show: $showEnergyEntry) { energy in
                    if let mood = tempMood {
                        let today = Date()
                        let calendar = Calendar.current
                        
                        // Remove any existing entry for today
                        entries.removeAll { entry in
                            calendar.isDate(entry.date, inSameDayAs: today)
                        }
                        
                        // Add the new entry for today
                        entries.append(MoodLogEntry(date: today, mood: mood, energy: energy))
                        tempMood = nil
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Mood tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryGreen)
                Text("Track your mood and energy levels throughout the week to identify patterns.")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }

    private var logButton: some View {
        Button(action: {
            showMoodEntry = true
        }) {
            Text("Log energy levels")
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.primaryGreen)
                .cornerRadius(12)
        }
    }

    // Helper function to get entries for the current week or month based on selectedTab
    private var filteredEntries: [MoodLogEntry] {
        let calendar = Calendar.current
        
        if selectedTab == "Week" {
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate) else {
                return []
            }
            let weekStart = weekInterval.start
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekInterval.end
            
            return entries.filter { entry in
                entry.date >= weekStart && entry.date < weekEnd
            }
        } else {
            guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
                return []
            }
            let monthStart = monthInterval.start
            let monthEnd = monthInterval.end
            
            return entries.filter { entry in
                entry.date >= monthStart && entry.date < monthEnd
            }
        }
    }
    
    private var hasMoodData: Bool {
        !filteredEntries.isEmpty
    }
    
    // Helper function to calculate median mood from filtered entries
    private var medianMood: MoodType {
        guard hasMoodData else { return .neutral }
        
        // Assign numeric values to moods for median calculation
        let moodValues: [MoodType: Int] = [
            .depressed: 1,
            .sad: 2,
            .neutral: 3,
            .happy: 4,
            .veryHappy: 5
        ]
        
        let sortedMoods = filteredEntries.map { $0.mood }.sorted { mood1, mood2 in
            (moodValues[mood1] ?? 3) < (moodValues[mood2] ?? 3)
        }
        
        let medianIndex = sortedMoods.count / 2
        return sortedMoods[medianIndex]
    }
    
    // Helper function to calculate average energy level from filtered entries
    private var averageEnergyLevel: Double {
        guard hasMoodData else { return 0 }
        let totalEnergy = filteredEntries.reduce(0) { $0 + $1.energy }
        return Double(totalEnergy) / Double(filteredEntries.count)
    }
    
    // Helper function to get emotion icon name for a mood
    private func emotionIconName(for mood: MoodType) -> String {
        switch mood {
        case .depressed: return "Emotion depressed"
        case .sad: return "Emotion sad"
        case .neutral: return "Emotion neutral"
        case .happy: return "Emotion happy"
        case .veryHappy: return "Emotion overjoyed"
        }
    }
    
    // Median mood and Average energy levels summary card section
    private var moodTrackerSummary: some View {
        ZStack(alignment: .top) {
            // Card background
            VStack(spacing: 8) {
                if hasMoodData {
                    // Median mood label inside the card
                    Text(medianMood.rawValue)
                        .font(.custom("Noto Sans", size: 48))
                        .foregroundColor(Color.secondaryGreen)
                    
                    // Average energy level inside the card
                    Text("Avg energy level: \(String(format: "%.1f", averageEnergyLevel))/10")
                        .font(.custom("Noto Sans", size: 15))
                        .foregroundColor(Color.darkGrayText)
                } else {
                    Text("No data yet")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(Color.darkGrayText)
                    
                    Text("Log your mood and energy to see your weekly or monthly summary.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 20)
            .padding(.bottom, 24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
            
            // Emotion icon above the top edge of the card (only when there is data)
            if hasMoodData {
                Image(emotionIconName(for: medianMood))
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color.secondaryGreen)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(medianMood == .neutral ? 2.6 : 1.0, anchor: .center)
                    .frame(width: 80, height: 80)
                    .offset(y: -50) // Position icon above the card
            }
        }
        .padding(.top, hasMoodData ? 50 : 0)
    }

    // Week and Month toggle buttons on Mood Tracker page
    private var toggleTabs: some View {
        HStack(spacing: 8) {
            toggleButton("Week")
            toggleButton("Month")
        }
        .padding(.vertical, 10)
    }

    private func toggleButton(_ title: String) -> some View {
        Button(title) {
            selectedTab = title
        }
        .font(.headline)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(selectedTab == title ? Color.secondaryGreen : Color.white)
        .foregroundColor(selectedTab == title ? .white : .gray)
        .cornerRadius(8)
        .shadow(color: selectedTab == title ? .clear : Color.neutralShadow, radius: 4, x: 0, y: 4)
    }

    // Calendar section users can navigate on
    private var calendarSection: some View {
        MoodCalendarView(currentDate: $currentDate, entries: entries, selectedTab: selectedTab)
    }

    // Energy levels chart
    private var energyChart: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Energy levels")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.darkGrayText)
            
            // Dynamically adjust height of empty space for popover to appear without overlapping any text
            Spacer()
                .frame(height: selectedBarIndex != nil ? 60 : 15)
                .animation(.easeInOut(duration: 0.3), value: selectedBarIndex)
            
            Chart {
                ForEach(Array(energyChartData.enumerated()), id: \.element.id) { index, point in
                    let isSelected = selectedBarIndex == index
                    
                    BarMark(
                        x: .value("Label", point.label),
                        y: .value("Energy", point.energy)
                    )
                    .foregroundStyle(isSelected ? Color.secondaryGreen : Color.barDefault)
                    .cornerRadius(4)
                    
                    // Popover annotation and connecting line for selected bar
                    // Only show popover if there's a logged entry
                    if isSelected && point.hasEntry {
                        // Vertical dashed line from popover to bar
                        RuleMark(x: .value("Label", point.label))
                            .foregroundStyle(Color.secondaryGreen)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))
                            .annotation(position: .top, alignment: .center, spacing: 0) {
                                energyTooltip(energy: point.energy)
                            }
                    }
                }
            }
            .frame(height: 260) // Extra height to accommodate popover
            .chartXAxis {
                if selectedTab == "Month" {
                    // For month mode, only show labels at days 1, 7, 14, 21, 28
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
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
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 2, 4, 6, 8, 10]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3, dash: [0, 0]))
                    AxisValueLabel(horizontalSpacing: 16)
                }
            }
            .fontWeight(.medium)
            .chartYScale(domain: 0...10)
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
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
        .onChange(of: selectedTab) { _, _ in
            // Dismiss popover when switching tabs
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedBarIndex = nil
            }
        }
    }
    
    private var xAxisFontSize: CGFloat {
        switch selectedTab {
        case "Week":
            return 13
        case "Month":
            return 12
        default:
            return 12
        }
    }
    
    private var energyChartData: [EnergyChartDataPoint] {
        let calendar = Calendar.current
        
        if selectedTab == "Week" {
            // Get the current week's date range based on the calendar's currentDate
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate) else {
                return []
            }
            let weekStart = weekInterval.start
            
            // Create data points for each day of the week
            return (0..<7).compactMap { offset -> EnergyChartDataPoint? in
                guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                    return nil
                }
                
                // Get day abbreviation (Sun, Mon, Tue, etc.)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE"
                let label = String(dateFormatter.string(from: date).prefix(3))
                
                // Find entry for this date
                let entry = entries.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
                let energy = entry?.energy ?? 0
                let hasEntry = entry != nil
                
                return EnergyChartDataPoint(id: UUID(), label: label, energy: energy, date: date, hasEntry: hasEntry)
            }
        } else {
            // Month mode - get the current month's date range based on the calendar's currentDate
            guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
                return []
            }
            
            var dates: [Date] = []
            var date = monthInterval.start
            while date < monthInterval.end {
                dates.append(date)
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
                date = nextDate
            }
            
            // Create data points for each day of the month
            return dates.map { date in
                let day = calendar.component(.day, from: date)
                let label = "\(day)"
                
                // Find entry for this date
                let entry = entries.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
                let energy = entry?.energy ?? 0
                let hasEntry = entry != nil
                
                return EnergyChartDataPoint(id: UUID(), label: label, energy: energy, date: date, hasEntry: hasEntry)
            }
        }
    }
    
    // MARK: - Energy Tooltip
    private func energyTooltip(energy: Int) -> some View {
        VStack(spacing: 0) {
            // Popover
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(energy)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.secondaryGreen)
            .cornerRadius(8)
            
            // Pointing triangle
            EnergyPopoverArrow()
                .fill(Color.secondaryGreen)
                .frame(width: 12, height: 6)
        }
        .fixedSize()
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
        let dataCount = CGFloat(energyChartData.count)
        guard dataCount > 0 else { return }
        
        let barWidth = plotArea.width / dataCount
        let tappedIndex = Int(relativeX / barWidth)
        
        guard tappedIndex >= 0 && tappedIndex < energyChartData.count else {
            // Animate spacer height change when dismissing popover for invalid tap index
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedBarIndex = nil
            }
            return
        }
        
        // Only allow selection if there's a logged entry
        let tappedData = energyChartData[tappedIndex]
        if !tappedData.hasEntry {
            // If tapping on a bar with no logged entry, just deselect any current selection
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

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(.primaryGreen)
            
            // Display insights only if there is data
            if !entries.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    MoodInsightRow(number: 1, text: "On the days you get more than 8 hours of sleep, you tend to have a 20% increase in energy levels as compared to your average.", isLast: true)
                }
            } else {
                Text("No data available to generate insights")
                    .font(.custom("Noto Sans", size: 16))
                    .foregroundColor(.darkGrayText)
                    .padding(.vertical, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 30)
    }
}

// Calendar interface with each day recorded with a mood marked
struct MoodCalendarView: View {
    @Binding var currentDate: Date
    let entries: [MoodLogEntry]
    let selectedTab: String
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private var daysInMonth: [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentDate) else { return [] }
        var dates: [Date] = []
        var date = monthInterval.start
        while date < monthInterval.end {
            dates.append(date)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        }
        return dates
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header with navigation
            HStack {
                Button(action: {
                    navigatePeriod(forward: false)
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(periodHeaderText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    navigatePeriod(forward: true)
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            if selectedTab == "Month" {
                monthCalendarView
            } else {
                weekCalendarView
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
    }
    
    // Month Calendar View
    private var monthCalendarView: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(["Su", "M", "T", "W", "Th", "F", "Sa"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            let firstWeekday = Calendar.current.component(.weekday, from: daysInMonth.first ?? Date()) - 1
            ForEach(0..<firstWeekday, id: \.self) { _ in
                Text("").frame(height: 32)
            }

            ForEach(daysInMonth, id: \.self) { date in
                dayCell(for: date, isCurrentMonth: true)
            }
        }
    }
    
    // Week Calendar View
    private var weekCalendarView: some View {
        VStack(spacing: 10) {
            // Day headers
            let columns = ["Su", "M", "T", "W", "Th", "F", "Sa"]
            HStack {
                ForEach(columns, id: \.self) {
                    Text($0)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Week days
            let calendar = Calendar.current
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate)!
            let weekStart = weekInterval.start
            let weekDays = (0..<7).compactMap { offset -> Date? in
                calendar.date(byAdding: .day, value: offset, to: weekStart)
            }
            
            HStack {
                ForEach(weekDays, id: \.self) { date in
                    dayCell(for: date, isCurrentMonth: true)
                }
            }
        }
        .padding(.horizontal, 12)
    }

    private func dayCell(for date: Date, isCurrentMonth: Bool) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let dateStartOfDay = calendar.startOfDay(for: date)
        let moodColor = moodColor(for: date)
        let isToday = calendar.isDate(dateStartOfDay, inSameDayAs: today)
        let hasMoodEntry = moodColor != .clear

        return ZStack {
            if hasMoodEntry {
                Circle()
                    .fill(moodColor)
                    .frame(width: 32, height: 32)
            } else if isToday {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
            }

            Text("\(day)")
                .font(.subheadline)
                .foregroundColor(
                    hasMoodEntry || isToday ? .white : (isCurrentMonth ? .primary : .clear)
                )
                .frame(height: 32)
        }
        .frame(maxWidth: .infinity)
    }

    private func moodColor(for date: Date) -> Color {
        if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return entry.mood.color
        }
        return .clear
    }
    
    // Helper Properties and Functions
    private var periodHeaderText: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if selectedTab == "Week" {
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate)!
            let weekStart = weekInterval.start
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            formatter.dateFormat = "MMM d"
            let startString = formatter.string(from: weekStart)
            formatter.dateFormat = "MMM d, yyyy"
            let endString = formatter.string(from: weekEnd)
            
            return "\(startString) - \(endString)"
        } else {
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentDate)
        }
    }
    
    private func navigatePeriod(forward: Bool) {
        let calendar = Calendar.current
        let value = forward ? 1 : -1
        
        if selectedTab == "Month" {
            if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
                currentDate = newDate
            }
        } else {
            if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: currentDate) {
                currentDate = newDate
            }
        }
    }
}

private extension Color {
    static let barDefault = Color(red: 0.682, green: 0.698, blue: 0.788)
    
    // Emotion-specific associated colors
    static let depressedColor = Color(red: 0.678, green: 0.098, blue: 0.078)
    static let sadColor = Color(red: 0.756, green: 0.420, blue: 0.196)
    static let neutralColor = Color(red: 0.905, green: 0.694, blue: 0.329)
    static let happyColor = Color(red: 0.878, green: 0.772, blue: 0.462)
    static let overjoyedColor = Color(red: 0.486, green: 0.619, blue: 0.415)
}

// MARK: - Insight Row Component
struct MoodInsightRow: View {
    let number: Int
    let text: String
    let isLast: Bool
    
    // #F0F1F9 converted to RGB (240/255, 241/255, 249/255)
    private let bulletBackgroundColor = Color(red: 240/255, green: 241/255, blue: 249/255)
    private let numberColor = Color.primaryGreen
    
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


// MARK: - Energy Chart Data Point
struct EnergyChartDataPoint: Identifiable {
    let id: UUID
    let label: String
    let energy: Int
    let date: Date
    let hasEntry: Bool
}

// MARK: - Popover Arrow Shape
struct EnergyPopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct MoodTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTrackerView()
    }
}
