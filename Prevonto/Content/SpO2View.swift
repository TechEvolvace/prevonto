// SpO2 page displays the user's SpO2 levels across days, weeks or months.
import SwiftUI
import Charts

struct SpO2View: View {
    @State private var selectedTab = "Week"
    @State private var selectedDay = "Wed 14"
    @State private var avgSpO2 = 95.0
    @State private var avgHeartRate = 60.0
    @State private var lowestSpO2 = 95.0
    @State private var selectedDataIndex: Int? = nil
    
    // Obviously hardcoded data right now is used.
    let timelineData: [(String, Double)] = [
        ("Mon", 94), ("Tue", 95), ("Wed", 96), ("Thu", 95),
        ("Fri", 93), ("Sat", 92), ("Sun", 94)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                    .onTapGesture { unselectChartData() }
                toggleTabs
                    .onTapGesture { unselectChartData() }
                calendarSection
                    .onTapGesture { unselectChartData() }
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
            
            Chart {
                ForEach(Array(timelineData.enumerated()), id: \.offset) { index, data in
                    let (day, value) = data
                    
                    // Gradient area fill from line to x-axis
                    AreaMark(
                        x: .value("Day", day),
                        yStart: .value("SpO2", 80),
                        yEnd: .value("SpO2", value)
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
                        x: .value("Day", day),
                        y: .value("SpO2", value)
                    )
                    .foregroundStyle(Color.secondaryColor)
                    .interpolationMethod(.monotone)
                    
                    PointMark(
                        x: .value("Day", day),
                        y: .value("SpO2", value)
                    )
                    .foregroundStyle(selectedDataIndex == index ? Color(red: 96/255, green: 142/255, blue: 97/255) : Color.secondaryColor)
                    .symbolSize(selectedDataIndex == index ? 100 : 60)
                    .annotation(position: .top, alignment: .center, spacing: 4) {
                        if selectedDataIndex == index {
                            chartTooltip(value: value)
                        }
                    }
                }
            }
            .chartYScale(domain: 80...100)  // 🔥 Vertical axis 80 to 100
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 200)
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
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
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
    
    private func handleChartTap(at location: CGPoint, geometry: GeometryProxy) {
        let chartWidth = geometry.size.width
        let barWidth = chartWidth / CGFloat(timelineData.count)
        let tappedIndex = Int(location.x / barWidth)
        
        guard tappedIndex >= 0 && tappedIndex < timelineData.count else {
            selectedDataIndex = nil
            return
        }
        
        if selectedDataIndex == tappedIndex {
            selectedDataIndex = nil
        } else {
            selectedDataIndex = tappedIndex
        }
    }
    
    private func unselectChartData() {
        selectedDataIndex = nil
    }

}

struct SegmentedSpO2Gauge: View {
    var value: Double  // 0 to 100
    
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
    
    var body: some View {
        ZStack {
            // Background colors for the 4 SpO2 gauge segments
            CircleSegment(start: 0.00, end: segment1End, color: firstSegmentColor)
            CircleSegment(start: segment2Start, end: segment2End, color: secondSegmentColor)
            CircleSegment(start: segment3Start, end: segment3End, color: thirdSegmentColor)
            CircleSegment(start: segment4Start, end: segment4End, color: fourthSegmentColor)
            
            // Foreground segments (filled based on value)
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
            
            // Circle indicator showing the current SpO2 value position
            // The indicator is positioned at the end of the filled portion of the gauge
            if valuePosition >= 0 && valuePosition <= 0.75 {
                CircleIndicator(position: valuePosition)
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
            .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .butt))
    }
}

struct CircleIndicator: View {
    var position: Double  // Position on the circle (0 to 0.75)
    
    var body: some View {
        GeometryReader { geometry in
            IndicatorPointShadow(position: position)
                .fill(Color.white)
            IndicatorPointShape(position: position)
                .fill(Color.secondaryColor)
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
