import SwiftUI
import Charts

struct ContentView: View {
    @State private var stepCount: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    @State private var heartRate: Double = 60
    @State private var authorizationStatus: String = "Not Requested"
    @State private var showingQuickActions = false
    
    // Time period selection
    @State private var selectedTimePeriod: TimePeriod = .thisMonth
    
    // Carousel states
    @State private var healthHighlightsCurrentIndex = 0
    @State private var medicationCurrentIndex = 0
    
    // Activity ring data
    @State private var caloriesProgress: Double = 0.6
    @State private var exerciseProgress: Double = 0.8
    @State private var standProgress: Double = 0.4
    
    let healthKitManager = HealthKitManager()
    
    // Sample medication data
    private let medications = [
        Medication(name: "Medication", instructions: "Instructions for intake", time: "10:00 AM"),
        Medication(name: "Medicine B", instructions: "Take with food", time: "6:00 PM"),
        Medication(name: "Supplement", instructions: "Once daily", time: "8:00 AM")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    quickHealthSection
                    healthHighlightsSection
                    medicationSection
                    trackingPatternSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingQuickActions) {
                QuickActionsModal()
            }
        }
        .onAppear {
            loadHealthData()
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back!")
                    .font(.custom("Noto Sans", size: 28))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    // Search functionality
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                }
                
                Button(action: {
                    // Paperclip functionality
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                }
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Quick Health Section
    var quickHealthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quick Health")
                    .font(.custom("Noto Sans", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                
                Spacer()
                
                Menu {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(period.rawValue) {
                            selectedTimePeriod = period
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedTimePeriod.rawValue)
                            .font(.custom("Noto Sans", size: 16))
                            .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                    )
                }
            }
            
            HStack(spacing: 16) {
                // Activity Rings Card
                NavigationLink(destination: StepsDetailsView()) {
                    activityRingsCard
                }
                .buttonStyle(PlainButtonStyle())
                
                // Heart Rate Card
                NavigationLink(destination: HeartRateView()) {
                    heartRateCard
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Activity Rings Card
    var activityRingsCard: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outermost ring (Stand)
                Circle()
                    .stroke(Color(red: 0.14, green: 0.20, blue: 0.08).opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: standProgress)
                    .stroke(Color(red: 0.14, green: 0.20, blue: 0.08), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                // Middle ring (Exercise)
                Circle()
                    .stroke(Color(red: 0.36, green: 0.51, blue: 0.36).opacity(0.2), lineWidth: 12)
                    .frame(width: 90, height: 90)
                
                Circle()
                    .trim(from: 0, to: exerciseProgress)
                    .stroke(Color(red: 0.36, green: 0.51, blue: 0.36), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                
                // Innermost ring (Calories)
                Circle()
                    .stroke(Color(red: 0.51, green: 0.64, blue: 0.51).opacity(0.2), lineWidth: 12)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: caloriesProgress)
                    .stroke(Color(red: 0.51, green: 0.64, blue: 0.51), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
            }
            
            Text("Almost there!")
                .font(.custom("Noto Sans", size: 14))
                .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                .padding(.top, 4)
                .padding(.bottom, 2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Heart Rate Card
    var heartRateCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(heartRate))")
                        .font(.custom("Noto Sans", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.368, green: 0.553, blue: 0.372))
                    Text("bpm")
                        .font(.custom("Noto Sans", size: 18))
                        .foregroundColor(Color(red: 0.368, green: 0.553, blue: 0.372))
                    Spacer()
                }
                
                Text("Avg Heart Rate")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
            }
            
            // Heart rate chart with gradient
            ZStack {
                // Background bars
                HStack(spacing: 12) {
                    ForEach(0..<12) { _ in
                        Rectangle()
                            .fill(Color(red: 0.74, green: 0.77, blue: 0.82).opacity(0.25))
                            .frame(width: 1, height: 60)
                    }
                }
                
                // Area chart with gradient from line to bottom
                Path { path in
                    let width = 120.0
                    let height = 60.0
                    let points = [0.3, 0.5, 0.2, 0.7, 0.4, 0.8, 0.6, 0.3, 0.5, 0.4, 0.6, 0.2]
                    
                    // Start from bottom left
                    path.move(to: CGPoint(x: 0, y: height))
                    
                    // Draw to first point
                    path.addLine(to: CGPoint(x: 0, y: height * (1 - points[0])))
                    
                    // Draw the line
                    for i in 1..<points.count {
                        let x = (width / Double(points.count - 1)) * Double(i)
                        let y = height * (1 - points[i])
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    // Close the path to bottom
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.49, green: 0.62, blue: 0.42).opacity(0.6),
                            Color(red: 0.49, green: 0.62, blue: 0.42).opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 60)
                
                // Line on top
                Path { path in
                    let width = 120.0
                    let height = 60.0
                    let points = [0.3, 0.5, 0.2, 0.7, 0.4, 0.8, 0.6, 0.3, 0.5, 0.4, 0.6, 0.2]
                    
                    path.move(to: CGPoint(x: 0, y: height * (1 - points[0])))
                    for i in 1..<points.count {
                        let x = (width / Double(points.count - 1)) * Double(i)
                        let y = height * (1 - points[i])
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color(red: 0.49, green: 0.62, blue: 0.42), lineWidth: 2)
                .frame(height: 60)
            }
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Health Highlights Section
    var healthHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health highlights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            TabView(selection: $healthHighlightsCurrentIndex) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.96, green: 0.97, blue: 0.98))
                        .frame(height: 120)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 120)
            
            // Custom page indicators
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index == healthHighlightsCurrentIndex ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.5))
                        .frame(width: index == healthHighlightsCurrentIndex ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: healthHighlightsCurrentIndex)
                }
            }
        }
    }
    
    // MARK: - Medication Section
    var medicationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your medication")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            // Medication card carousel
            TabView(selection: $medicationCurrentIndex) {
                ForEach(medications.indices, id: \.self) { index in
                    medicationCard(medication: medications[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 100)
            
            // Custom page indicators for medication
            HStack(spacing: 8) {
                ForEach(medications.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index == medicationCurrentIndex ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.5))
                        .frame(width: index == medicationCurrentIndex ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: medicationCurrentIndex)
                }
            }
            
            // Reminders and Adherence section
            HStack(spacing: 16) {
                // Reminders card
                remindersCard
                
                // Adherence card
                adherenceCard
            }
        }
    }
    
    // MARK: - Medication Card
    func medicationCard(medication: Medication) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(medication.instructions)
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button("Skipped") {
                    // Skip action
                }
                .font(.custom("Noto Sans", size: 14))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                .cornerRadius(8)
                
                Button("Taken") {
                    // Taken action
                }
                .font(.custom("Noto Sans", size: 14))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 0.02, green: 0.33, blue: 0.18))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Reminders Card
    var remindersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminders")
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "pills.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                    Text("Medicine, 10:00 AM")
                        .font(.custom("Noto Sans", size: 12))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    Text("Medicine, 11:00 AM")
                        .font(.custom("Noto Sans", size: 12))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Adherence Card
    var adherenceCard: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.73)
                    .stroke(Color(red: 0.02, green: 0.33, blue: 0.18), lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("73%")
                    .font(.custom("Noto Sans", size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 2) {
                Text("Adherence")
                    .font(.custom("Noto Sans", size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text("14 to 21")
                    .font(.custom("Noto Sans", size: 10))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                
                Text("May 2025")
                    .font(.custom("Noto Sans", size: 10))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Tracking Pattern Section
    var trackingPatternSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Tracking pattern")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Functions
    private func loadHealthData() {
        // Load health data from HealthKit
        healthKitManager.requestAuthorization { success, error in
            if success {
                DispatchQueue.main.async {
                    authorizationStatus = "Authorized"
                }
                
                healthKitManager.fetchTodayStepCount { steps, error in
                    if let steps = steps {
                        DispatchQueue.main.async {
                            stepCount = steps
                        }
                    }
                }
                
                healthKitManager.fetchTodayCalories { cals, error in
                    if let cals = cals {
                        DispatchQueue.main.async {
                            calories = cals
                        }
                    }
                }
                
                healthKitManager.fetchTodayDistance { distanceValue, error in
                    if let distanceValue = distanceValue {
                        DispatchQueue.main.async {
                            distance = distanceValue
                        }
                    }
                }
                
                healthKitManager.fetchTodayHeartRate { hr, error in
                    if let hr = hr {
                        DispatchQueue.main.async {
                            heartRate = hr
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    authorizationStatus = "Authorization Failed"
                }
            }
        }
    }
}

// MARK: - Supporting Models and Enums
enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This week"
    case thisMonth = "This month"
    case thisYear = "This year"
}

struct Medication {
    let name: String
    let instructions: String
    let time: String
}

// MARK: - Quick Actions Modal (unchanged from original)
struct QuickActionsModal: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Quick Actions")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    NavigationLink(destination: WeightTrackerView()) {
                        QuickActionButtonView(
                            icon: "scalemass.fill",
                            title: "Input Weight",
                            color: .blue
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: MoodTrackerView()) {
                        QuickActionButtonView(
                            icon: "face.smiling.fill",
                            title: "Input Mood",
                            color: .green
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: BloodGlucoseView()) {
                        QuickActionButtonView(
                            icon: "drop.fill",
                            title: "Blood Glucose",
                            color: .red
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                
                Spacer()
                
                // Navigation buttons for other features
                VStack(spacing: 12) {
                    NavigationLink("SpO2 Display", destination: SpO2View())
                        .buttonStyle(.borderedProminent)
                    NavigationLink("Steps Details", destination: StepsDetailsView())
                        .buttonStyle(.borderedProminent)
                    NavigationLink("Heart Rate", destination: HeartRateView())
                        .buttonStyle(.borderedProminent)
                    NavigationLink("Days Tracked", destination: DaysTrackedView())
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Quick Action Button Components (unchanged from original)
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(12)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionButtonView: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(12)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
