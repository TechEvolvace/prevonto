// Blood Glucose page allows user to see their blood glucose levels by day, week, or month. 
import SwiftUI
import Charts

struct BloodGlucoseView: View {
    @Environment(\.dismiss) private var dismiss
    
    private enum GlucoseTimeFrame: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }

    @State private var selectedTimeFrame: GlucoseTimeFrame = .day
    @State private var selectedDate: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 14)) ?? Date()
    
    private let glucoseData: [Double] = [95, 90, 100, 120, 130, 145, 125]
    private let hourlyLabels = ["12a", "3a", "6a", "9a", "12p", "3p", "6p", "9p"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Blood glucose")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.proPrimary)
                    Text("Your blood glucose levels must be recorded by you on a bi-weekly basis.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Current Reading
                VStack(spacing: 4) {
                    Text("108")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.proPrimary)
                    + Text(" mg/dl")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Weekly Average")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.1), radius: 6)
                .padding(.horizontal, 24)
                
                // Timeframe Buttons
                HStack(spacing: 12) {
                    ForEach(GlucoseTimeFrame.allCases, id: \.self) { tf in
                        Button(action: {
                            selectedTimeFrame = tf
                        }) {
                            Text(tf.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedTimeFrame == tf ? .white : .gray)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 20)
                                .background(selectedTimeFrame == tf ? Color.proPrimary : Color.white)
                                .cornerRadius(8)
                                .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Date Selector (shown in all modes)
                dateSelectorBar
                
                // Dynamic Chart Section
                chartSection
                
                // Highlights Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Highlights")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    ForEach(1...2, id: \.self) { index in
                        HStack {
                            Circle()
                                .fill(Color.proPrimary.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("\(index)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.proPrimary)
                                )
                            Text("xyz")
                                .font(.subheadline)
                                .foregroundColor(.proPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 50)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // MARK: - Date Selector Bar
    private var dateSelectorBar: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("May 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 6) {
                let formatter = DateFormatter()
                let calendar = Calendar.current
                let weekRange = (12...18).compactMap {
                    calendar.date(from: DateComponents(year: 2025, month: 5, day: $0))
                }
                
                ForEach(weekRange, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let label = formatter.string(from: date)
                    let dayNum = calendar.component(.day, from: date)
                    
                    VStack(spacing: 2) {
                        Text(label)
                            .font(.caption2)
                            .foregroundColor(isSelected ? .white : .gray)
                        Text("\(dayNum)")
                            .font(.caption)
                            .foregroundColor(isSelected ? .white : .gray)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(isSelected ? Color.proPrimary : Color.white)
                    .cornerRadius(6)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(spacing: 12) {
            switch selectedTimeFrame {
            case .day:
                dayChart
            case .week:
                weekChart
            case .month:
                monthChart
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 4)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Charts
    private var dayChart: some View {
        Chart {
            ForEach(glucoseData.indices, id: \.self) { i in
                LineMark(
                    x: .value("Hour", hourlyLabels[i]),
                    y: .value("mg/dl", glucoseData[i])
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.proPrimary)
            }
        }
        .frame(height: 160)
    }
    
    private var weekChart: some View {
        let days = ["Su", "M", "T", "W", "Th", "F", "Sa"]
        let values: [(min: Double, max: Double)] = [
            (60, 150), (70, 140), (80, 160),
            (50, 145), (55, 130), (65, 135), (75, 125)
        ]
        
        return Chart {
            ForEach(values.indices, id: \.self) { i in
                BarMark(
                    x: .value("Day", days[i]),
                    yStart: .value("Min", values[i].min),
                    yEnd: .value("Max", values[i].max)
                )
                .foregroundStyle(i == 3 ? Color.proPrimary : Color.gray.opacity(0.4))
            }
            PointMark(x: .value("Day", "W"), y: .value("Max", 145))
                .annotation {
                    Text("145 mg/dl").font(.caption2).foregroundColor(.proPrimary)
                }
            PointMark(x: .value("Day", "W"), y: .value("Min", 50))
                .annotation(position: .bottom) {
                    Text("50 mg/dl").font(.caption2).foregroundColor(.proPrimary)
                }
        }
        .frame(height: 160)
    }
    
    private var monthChart: some View {
        let weekLabels = ["1", "7", "14", "21", "28"]
        let values: [(min: Double, max: Double)] = [
            (65, 155), (60, 140), (75, 160), (50, 145), (70, 135)
        ]
        
        return Chart {
            ForEach(values.indices, id: \.self) { i in
                BarMark(
                    x: .value("Week", weekLabels[i]),
                    yStart: .value("Min", values[i].min),
                    yEnd: .value("Max", values[i].max)
                )
                .foregroundStyle(i == 3 ? Color.proPrimary : Color.gray.opacity(0.4))
            }
            PointMark(x: .value("Week", "21"), y: .value("Max", 145))
                .annotation {
                    Text("145 mg/dl").font(.caption2).foregroundColor(.proPrimary)
                }
            PointMark(x: .value("Week", "21"), y: .value("Min", 50))
                .annotation(position: .bottom) {
                    Text("50 mg/dl").font(.caption2).foregroundColor(.proPrimary)
                }
        }
        .frame(height: 160)
    }
}

// MARK: - Color Extensions
private extension Color {
    static let proPrimary = Color(red: 0.01, green: 0.33, blue: 0.18)
}

struct BloodGlucoseView_Previews: PreviewProvider {
    static var previews: some View {
        BloodGlucoseView()
    }
}
