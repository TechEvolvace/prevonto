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
                    .fill(step <= currentStep ? Color.primaryColor : Color.gray.opacity(0.3))
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
                .background(Color.primaryColor)
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

                // Scrollable, vertical selection of energy levels from 1 through 10
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(1...10, id: \.self) { val in
                            Text("\(val)")
                                .font(.system(size: val == selectedEnergy ? 48 : 32, weight: .bold))
                                .frame(width: 80, height: 80)
                                .background(val == selectedEnergy ? Color.secondaryColor : Color.clear)
                                .cornerRadius(12)
                                .foregroundColor(val == selectedEnergy ? .white : .gray)
                                .onTapGesture {
                                    selectedEnergy = val
                                }
                        }
                    }
                }
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
                .background(Color.primaryColor)
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

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    logButton
                    moodSummary
                    toggleTabs
                    calendarSection
                    energyChart
                    insightSection
                }
                .padding()
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
                        entries.append(MoodLogEntry(date: Date(), mood: mood, energy: energy))
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
                    .foregroundColor(.primaryColor)
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
                .background(Color.primaryColor)
                .cornerRadius(12)
        }
    }

    private var moodSummary: some View {
        VStack(spacing: 4) {
            Image(systemName: "face.smiling")
                .font(.largeTitle)
            Text("Neutral")
                .font(.headline)
            Text("Avg energy level: 7.5/10")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }

    // Week and Month toggle buttons on Mood Tracker page
    private var toggleTabs: some View {
        HStack(spacing: 8) {
            toggleButton("Week")
            toggleButton("Month")
        }
    }

    private func toggleButton(_ title: String) -> some View {
        Button(title) {
            selectedTab = title
        }
        .font(.headline)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(selectedTab == title ? Color.secondaryColor : Color.white)
        .foregroundColor(selectedTab == title ? .white : .gray)
        .cornerRadius(8)
        .shadow(color: selectedTab == title ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }

    private var calendarSection: some View {
        ExampleCalendarView(entries: entries)
    }

    private var energyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Energy levels")
                .font(.headline)
                .foregroundColor(.primaryColor)

            Chart {
                ForEach(entries) { entry in
                    BarMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Energy", entry.energy)
                    )
                    .foregroundStyle(Color.secondaryColor)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day(.defaultDigits))
                }
            }
            .chartYScale(domain: 0...10)
            .frame(height: 150)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Insight")
                .font(.headline)
                .foregroundColor(.primaryColor)

            HStack(alignment: .top) {
                Circle()
                    .fill(Color.secondaryColor.opacity(0.2))
                    .frame(width: 28, height: 28)
                    .overlay(Text("1").font(.footnote).foregroundColor(.primaryColor))
                Text("On the days you get more than 8 hours of sleep, you tend to have a 20% increase in energy levels as compared to your average.")
                    .font(.footnote)
                    .foregroundColor(.black)
            }
        }
    }
}


struct ExampleCalendarView: View {
    @State private var currentDate = Date()
    let entries: [MoodLogEntry]  // <- add this
    
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
        VStack(spacing: 8) {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(for: currentDate))
                    .font(.headline)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            let columns = Array(repeating: GridItem(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 8) {
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
                    dayCell(for: date)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }

    private func dayCell(for date: Date) -> some View {
        let day = Calendar.current.component(.day, from: date)
        let color = moodColor(for: date)

        return ZStack {
            if color != .clear {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
            }

            Text("\(day)")
                .foregroundColor(color == .clear ? .black : .white)
                .frame(height: 32)
        }
    }

    private func moodColor(for date: Date) -> Color {
        if let entry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return entry.mood.color
        }
        return .clear
    }

    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)
    
    // Emotion-specific associated colors
    static let depressedColor = Color(red: 0.678, green: 0.098, blue: 0.078)
    static let sadColor = Color(red: 0.756, green: 0.420, blue: 0.196)
    static let neutralColor = Color(red: 0.905, green: 0.694, blue: 0.329)
    static let happyColor = Color(red: 0.878, green: 0.772, blue: 0.462)
    static let overjoyedColor = Color(red: 0.486, green: 0.619, blue: 0.415)
}


struct MoodTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTrackerView()
    }
}
