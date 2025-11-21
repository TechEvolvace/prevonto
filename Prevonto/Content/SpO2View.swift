// SpO2 page displays the user's SpO2 levels across days, weeks or months.
import SwiftUI
import Charts

struct SpO2View: View {
    @State private var selectedTab = "Week"
    @State private var selectedDay = "Wed 14"
    @State private var avgSpO2 = 95.0
    @State private var avgHeartRate = 60.0
    @State private var lowestSpO2 = 95.0
    
    // Obviously hardcoded data right now is used.
    let timelineData: [(String, Double)] = [
        ("Mon", 94), ("Tue", 95), ("Wed", 96), ("Thu", 95),
        ("Fri", 93), ("Sat", 92), ("Sun", 94)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                toggleTabs
                calendarSection
                gaugeSection
                summarySection
                timelineChart
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .background(.white)
        .navigationTitle("SpO2 Full Page")
        .navigationBarTitleDisplayMode(.inline)
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
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(selectedTab == title ? Color.secondaryColor : .white)
        .foregroundColor(selectedTab == title ? .white : .gray)
        .font(.headline)
        .cornerRadius(8)
        .shadow(color: selectedTab == title ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
    
    private var calendarSection: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                }
                Text("May 2025")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Button(action: {}) {
                    Image(systemName: "chevron.right")
                }
            }
            
            HStack(spacing: 4) {
                ForEach(["Mon 12", "Tue 13", "Wed 14", "Thu 15", "Fri 16", "Sat 17", "Sun 18"], id: \.self) { day in
                    let isSelected = day == selectedDay
                    VStack(spacing: 4) {
                        Text(day.prefix(3))
                            .font(.caption2)
                        Button(action: {
                            selectedDay = day
                            avgSpO2 = Double.random(in: 93...97)
                            avgHeartRate = Double.random(in: 55...65)
                            lowestSpO2 = Double.random(in: 90...95)
                        }) {
                            Text(day.suffix(2))
                                .font(.caption)
                                .frame(width: 32, height: 32)
                                .background(isSelected ? Color.secondaryColor : Color.gray.opacity(0.2))
                                .foregroundColor(isSelected ? .white : .black)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
    }
    
    private var gaugeSection: some View {
        SegmentedSpO2Gauge(value: avgSpO2)
    }

    
    private var summarySection: some View {
        VStack(spacing: 8) {
            Divider()
            HStack {
                summaryItem(title: "Lowest SpO₂", value: "\(Int(lowestSpO2))%")
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
                .font(.headline)
                .foregroundColor(.primaryColor)
            
            Chart(timelineData, id: \.0) { day, value in
                LineMark(
                    x: .value("Day", day),
                    y: .value("SpO2", value)
                )
                .foregroundStyle(Color.secondaryColor)
                .interpolationMethod(.monotone)
                
                PointMark(
                    x: .value("Day", day),
                    y: .value("SpO2", value)
                )
                .foregroundStyle(Color.secondaryColor)
            }
            .chartYScale(domain: 80...100)  // 🔥 Vertical axis 80 to 100
            .frame(height: 200)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }

}

struct SegmentedSpO2Gauge: View {
    var value: Double  // 80 to 100
    
    // Initializing segment colors for this SpO2 gauge
    var firstSegmentColor = Color(red: 0.427, green: 0.243, blue: 0.058)
    var secondSegmentColor = Color(red: 0.776, green: 0.525, blue: 0.278)
    var thirdSegmentColor = Color(red: 0.949, green: 0.796, blue: 0.368)
    var fourthSegmentColor = Color.secondaryColor
    
    var body: some View {
        ZStack {
            // Background segments
            CircleSegment(start: 0.00, end: 0.1875, color: firstSegmentColor.opacity(0.2))
            CircleSegment(start: 0.1875, end: 0.375, color: secondSegmentColor.opacity(0.2))
            CircleSegment(start: 0.375, end: 0.5625, color: thirdSegmentColor.opacity(0.2))
            CircleSegment(start: 0.5625, end: 0.75, color: fourthSegmentColor.opacity(0.2))
            
            // Foreground segments
            if value > 80 {
                CircleSegment(start: 0.00, end: min(0.1875, (value - 80) / 20 * 0.75), color: firstSegmentColor)
            }
            if value > 85 {
                CircleSegment(start: 0.1875, end: min(0.375, (value - 80) / 20 * 0.75), color: secondSegmentColor)
            }
            if value > 90 {
                CircleSegment(start: 0.375, end: min(0.5625, (value - 80) / 20 * 0.75), color: thirdSegmentColor)
            }
            if value > 95 {
                CircleSegment(start: 0.5625, end: min(0.75, (value - 80) / 20 * 0.75), color: fourthSegmentColor)
            }
            
            // Center text
            VStack(spacing: 4) {
                Text("\(Int(value))%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryColor)
                Text("Avg SpO₂")
                    .font(.subheadline)
                    .foregroundColor(.gray)
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
            .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .butt))
    }
}


struct SpO2View_Previews: PreviewProvider {
    static var previews: some View {
        SpO2View()
    }
}
