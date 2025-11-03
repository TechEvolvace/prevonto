// Days tracked page shows what days the user have tracked their metrics on
import SwiftUI

struct DaysTrackedView: View {
    private enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }

    @State private var selectedPeriod: Period = .month
    @State private var selectedDate = Date()
    
    // Sample tracked days (for the calendar)
    private let trackedDays: Set<Int> = [12, 15, 16, 17, 18, 19, 24, 25]
    private let today = 27

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Days tracked\ncounter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.proPrimary)
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
                            .foregroundColor(.proPrimary)
                        Text("days")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Text("Most tracked: BP, Mood")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 6)
                .padding(.horizontal, 24)

                // Period Picker
                HStack(spacing: 12) {
                    ForEach(Period.allCases, id: \.self) { period in
                        Button {
                            selectedPeriod = period
                        } label: {
                            Text(period.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedPeriod == period ? .white : .gray)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 20)
                                .background(selectedPeriod == period ? Color.proPrimary : Color.white)
                                .cornerRadius(8)
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Calendar
                calendarView
                
                Spacer(minLength: 50)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    // Calendar Mockup
    private var calendarView: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chevron.left").foregroundColor(.gray)
                Spacer()
                Text("May 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            
            // Grid
            VStack(spacing: 10) {
                let columns = ["Su", "M", "T", "W", "Th", "F", "Sa"]
                HStack {
                    ForEach(columns, id: \.self) {
                        Text($0)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                let allDays = (1...31)
                let weeks = stride(from: 0, to: allDays.count, by: 7).map {
                    Array(allDays.dropFirst($0).prefix(7))
                }

                ForEach(weeks, id: \.self) { week in
                    HStack {
                        ForEach(week, id: \.self) { day in
                            ZStack {
                                if trackedDays.contains(day) {
                                    Circle()
                                        .fill(Color.proPrimary)
                                        .frame(width: 32, height: 32)
                                } else if day == today {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 32, height: 32)
                                }
                                
                                Text("\(day)")
                                    .font(.subheadline)
                                    .foregroundColor(trackedDays.contains(day) || day == today ? .white : .primary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4)
        .padding(.horizontal, 24)
    }
}

// MARK: - Color Extension
private extension Color {
    static let proPrimary = Color(red: 0.01, green: 0.33, blue: 0.18)
}

struct DaysTrackedView_Previews: PreviewProvider {
    static var previews: some View {
        DaysTrackedView()
    }
}
