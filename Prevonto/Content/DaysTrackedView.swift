// Days tracked page shows what days the user have tracked their metrics on
import SwiftUI

struct DaysTrackedView: View {
    private enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }

    @State private var selectedPeriod: Period = .month
    @State private var selectedDate = Date()
    
    // Sample tracked days (for the calendar) - using actual dates
    // These are sample dates that should be replaced with actual tracked dates from your data source
    // This is a computed property that returns tracked days for any month being viewed
    // Only includes dates up to today (no future dates)
    private var trackedDays: Set<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let viewedMonth = calendar.component(.month, from: selectedDate)
        let viewedYear = calendar.component(.year, from: selectedDate)
        
        // Sample tracked days in the viewed month
        // In a real implementation, this would query your data repository
        let allSampleDays = [
            Date.from(year: 2025, month: 10, day: 12),
            Date.from(year: 2025, month: 10, day: 15),
            Date.from(year: 2025, month: 11, day: 16),
            Date.from(year: 2025, month: 11, day: 17),
            Date.from(year: 2025, month: 11, day: 18),
            Date.from(year: 2025, month: 11, day: 19),
            Date.from(year: 2025, month: 11, day: 24),
            Date.from(year: 2025, month: 11, day: 25)
        ]
        
        // Filter out future dates - only include dates that are today or in the past
        return Set(allSampleDays.filter { date in
            let dateStartOfDay = calendar.startOfDay(for: date)
            return dateStartOfDay <= today
        })
    }
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Days tracked\ncounter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryGreen)
                    Text("Keep a tab on how frequently you track your metrics on the app.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Main Box
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("9")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color.secondaryGreen)
                        Text("days")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    Text("Most tracked: BP, Mood")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 6)
                .padding(.horizontal, 24)

                // Period Picker
                HStack(spacing: 8) {
                    ForEach(Period.allCases, id: \.self) { period in
                        Button {
                            selectedPeriod = period
                        } label: {
                            Text(period.rawValue)
                                .font(.headline)
                                .foregroundColor(selectedPeriod == period ? .white : .gray)
                                .padding(.vertical, 5)
                                .frame(maxWidth: .infinity)
                                .background(selectedPeriod == period ? Color.secondaryGreen : Color.white)
                                .cornerRadius(8)
                                .shadow(color: selectedPeriod == period ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Calendar
                calendarView
                
                Spacer(minLength: 50)
            }
            .background(.white)
        }
    }

    // Calendar View
    private var calendarView: some View {
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
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    navigatePeriod(forward: true)
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            
            // Calendar Grid
            if selectedPeriod == .month {
                monthCalendarView
            } else {
                weekCalendarView
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4)
        .padding(.horizontal, 24)
    }
    
    // Month Calendar View
    private var monthCalendarView: some View {
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
            
            // Calendar days - computed outside ViewBuilder
            let weeks = monthCalendarWeeks
            
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack {
                    ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            dayCell(for: date, isCurrentMonth: Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .month))
                        } else {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
    }
    
    // Computed property to generate month calendar weeks
    private var monthCalendarWeeks: [[Date?]] {
        let calendar = Calendar.current
        let monthInterval = calendar.dateInterval(of: .month, for: selectedDate)!
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1 // 0 = Sunday
        
        // Get all days in the month
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)!
        let monthDays = daysInMonth.compactMap { day -> Date? in
            calendar.date(bySetting: .day, value: day, of: firstDayOfMonth)
        }
        
        // Get days from previous month to fill the first week
        var allDays: [Date?] = []
        if firstWeekday > 0 {
            let previousMonthDays = (0..<firstWeekday).map { offset -> Date? in
                calendar.date(byAdding: .day, value: -(firstWeekday - offset), to: firstDayOfMonth)
            }
            allDays.append(contentsOf: previousMonthDays)
        }
        
        // Add current month days
        allDays.append(contentsOf: monthDays.map { $0 })
        
        // Fill remaining days to complete last week
        let remainingDays = 7 - (allDays.count % 7)
        if remainingDays < 7 {
            let lastDay = monthDays.last!
            let nextMonthDays = (1...remainingDays).compactMap { offset -> Date? in
                calendar.date(byAdding: .day, value: offset, to: lastDay)
            }
            allDays.append(contentsOf: nextMonthDays)
        }
        
        // Group into weeks
        return stride(from: 0, to: allDays.count, by: 7).map {
            Array(allDays[$0..<min($0 + 7, allDays.count)])
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
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)!
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
    
    // Day Cell
    private func dayCell(for date: Date, isCurrentMonth: Bool) -> some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let dateStartOfDay = calendar.startOfDay(for: date)
        let isTracked = trackedDays.contains(dateStartOfDay)
        let isToday = calendar.isDate(dateStartOfDay, inSameDayAs: today)
        
        return ZStack {
            if isTracked {
                Circle()
                    .fill(Color.completedGreen)
                    .frame(width: 32, height: 32)
            } else if isToday {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
            }
            
            Text("\(day)")
                .font(.subheadline)
                .foregroundColor(
                    isTracked || isToday ? .white : (isCurrentMonth ? .primary : .gray.opacity(0.5))
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    // Helper Properties and Functions
    private var periodHeaderText: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        if selectedPeriod == .week {
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)!
            let weekStart = weekInterval.start
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            formatter.dateFormat = "MMM d"
            let startString = formatter.string(from: weekStart)
            formatter.dateFormat = "MMM d, yyyy"
            let endString = formatter.string(from: weekEnd)
            
            return "\(startString) - \(endString)"
        } else {
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        }
    }
    
    private func navigatePeriod(forward: Bool) {
        let calendar = Calendar.current
        let value = forward ? 1 : -1
        
        if selectedPeriod == .month {
            if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
                selectedDate = newDate
            }
        } else {
            if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
                selectedDate = newDate
            }
        }
    }
}

// MARK: - Color Extension
private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)
    // Color to mark days tracked, same as primaryGreen
    static let completedGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
}

struct DaysTrackedView_Previews: PreviewProvider {
    static var previews: some View {
        DaysTrackedView()
    }
}
