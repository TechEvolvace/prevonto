//
//  MoodTrackerView.swift
//  Prevonto
//
//  Created by Yehjune Heo on 6/14/25.
//
import SwiftUI
import Charts

struct MoodLogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let mood: MoodType
    let energy: Int
}

enum MoodType: String, CaseIterable {
    case verySad = "Very Sad"
    case sad = "Sad"
    case neutral = "Neutral"
    case happy = "Happy"
    case veryHappy = "Very Happy"

    var color: Color {
        switch self {
        case .verySad: return .red
        case .sad: return .orange
        case .neutral: return .yellow
        case .happy: return .green
        case .veryHappy: return .blue
        }
    }

    var icon: String {
        switch self {
        case .verySad: return "😢"
        case .sad: return "🙁"
        case .neutral: return "😐"
        case .happy: return "🙂"
        case .veryHappy: return "😄"
        }
    }
}

struct MoodEntryCard: View {
    @Binding var show: Bool
    var onNext: (MoodType) -> Void
    @State private var selectedMood = MoodType.neutral

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text(Date(), style: .date)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                    Button("Clear") {
                        selectedMood = .neutral
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                }

                ProgressView(value: 0.5)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryColor))

                Text("1 of 2")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("How are you feeling today?")
                    .font(.headline)

                Picker("", selection: $selectedMood) {
                    ForEach(MoodType.allCases, id: \.self) { mood in
                        Text(mood.icon).tag(mood)
                    }
                }
                .pickerStyle(.wheel)

                Text("I'm feeling \(selectedMood.rawValue.lowercased()).")
                    .font(.subheadline)

                Button("Next") {
                    onNext(selectedMood)
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

struct EnergyEntryCard: View {
    @Binding var show: Bool
    var onSave: (Int) -> Void
    @State private var selectedEnergy = 7

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text(Date(), style: .date)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                    Button("Clear") {
                        selectedEnergy = 7
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                }

                ProgressView(value: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryColor))

                Text("2 of 2")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("What would you rate your energy levels?")
                    .font(.headline)
                    .multilineTextAlignment(.center)

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
                    .padding(.vertical, 40)
                }
                .frame(height: 300)

                Text("\(selectedEnergy)/10")
                    .font(.headline)

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
            .background(Color(UIColor.systemGroupedBackground))
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
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood tracker")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryColor)
                Text("Track your mood and energy levels throughout the week to identify patterns.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "xmark")
                .foregroundColor(.gray)
        }
    }

    private var logButton: some View {
        Button(action: {
            showMoodEntry = true
        }) {
            Text("Log energy levels")
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
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
        .frame(maxWidth: .infinity)
        .padding()
        .background(selectedTab == title ? Color.secondaryColor : Color.gray.opacity(0.2))
        .foregroundColor(selectedTab == title ? .white : .black)
        .cornerRadius(8)
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
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
        }
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


struct MoodTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodTrackerView()
    }
}
