// Dashboard page for the Prevonto app
import SwiftUI
import Charts

struct DashboardView: View {
    @State private var stepCount: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    @State private var heartRate: Double = 60
    @State private var authorizationStatus: String = "Not Requested"
    @State private var showingAddModal = false
    
    // Time period selection
    @State private var selectedTimePeriod: TimePeriod = .thisMonth
    
    // Carousel states
    @State private var healthHighlightsCurrentIndex = 0
    @State private var medicationCurrentIndex = 0
    
    // Activity ring data
    @State private var caloriesProgress: Double = 0.6
    @State private var exerciseProgress: Double = 0.8
    @State private var standProgress: Double = 0.4
    
    // Notification settings state
    @State private var showHeartRate: Bool = true
    @State private var showStepsActivity: Bool = true
    @State private var showBloodPressure: Bool = true
    @State private var showBloodGlucose: Bool = true
    @State private var showSpO2: Bool = true
    @State private var showWeight: Bool = true
    @State private var showMoodTracker: Bool = true
    @State private var showMedicationLog: Bool = true
    
    let healthKitManager = HealthKitManager()
    
    // API data state
    @State private var medications: [Medication] = []
    @State private var latestHeartRate: Double = 60
    @State private var latestBloodPressure: BloodPressureRecord?
    @State private var latestBloodGlucose: Double = 0
    @State private var latestSpO2: Double = 0
    @State private var latestWeight: Double = 0
    @State private var latestMood: EnergyMoodValue?
    @State private var isLoadingMetrics = false
    
    // Medication reminders and adherence
    @State private var upcomingReminders: [(name: String, time: Date)] = []
    @State private var adherencePercentage: Double = 0.0
    @State private var adherenceWeekRange: String = ""
    
    private let metricsService = MetricsService.shared
    private let onboardingService = OnboardingService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // All Dashboard Page Content that is not the floating + button
                ScrollView {
                        VStack(spacing: 32) {
                        VStack(spacing: 16){
                            headerSection
                            quickHealthSection
                        }
                        healthHighlightsSection
                        if showMedicationLog {
                            medicationSection
                        }
                        if showMoodTracker {
                            moodTrackerSection
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
                .background(Color.white)
                .navigationBarHidden(true)
                .onAppear {
                    loadNotificationSettings()
                    loadMetrics()
                }
                                
                // Floating + button, always visible in Dashboard page in same spot
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showingAddModal.toggle()
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color(red: 0.02, green: 0.33, blue: 0.18)) // Prevonto dark green
                                .frame(width: 56, height: 56)
                                .background(.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 34)
                    }
                }
                
                if showingAddModal {
                    // Dimmed backdrop + floating action stack
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            hideFloatingMenu()
                        }
                        .transition(.opacity)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            FloatingActionMenu(
                                actionTapped: { _ in
                                    hideFloatingMenu()
                                },
                                closeTapped: {
                                    hideFloatingMenu()
                                }
                            )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 34)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadHealthData()
                loadNotificationSettings()
            }
        }
    }
    
    // MARK: - Dashboard Header Section
    var headerSection: some View {
        HStack {
            // Welcome Back Message
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back!")
                    .font(.custom("Noto Sans", size: 32))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
            }
            
            Spacer()
            
            // Search Button
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
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                
                // New Settings Button
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Quick Health Section
    var quickHealthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Quick Health Snapshot subheading
                Text("Quick Health Snapshot")
                    .font(.custom("Noto Sans", size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                Spacer()
                
                // Dropdown menu selection
                // Following options to select: Today, This week, This month, This year
                Menu {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Button(period.rawValue) {
                            selectedTimePeriod = period
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedTimePeriod.rawValue)
                            .font(.custom("Noto Sans", size: 14))
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
            
            // Conditional Health Metrics Display in a 2 columns layout
            healthMetricsGrid
        }
    }
    
    // MARK: - Health Metrics Grid
    @ViewBuilder
    var healthMetricsGrid: some View {
        let hasAnyEnabled = showStepsActivity || showHeartRate || showBloodGlucose || showBloodPressure || showSpO2 || showWeight
        
        if !hasAnyEnabled {
            // If all metrics are disabled, show a placeholder
            VStack(spacing: 16) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.70, green: 0.70, blue: 0.70))
                
                Text("No health metrics enabled")
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    .multilineTextAlignment(.center)
                
                Text("Enable metrics in Notifications settings")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        } else {
            // 2-column grid layout
            let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
            LazyVGrid(columns: columns, spacing: 16) {
                if showStepsActivity {
                    NavigationLink(destination: StepsDetailsView()) {
                        activityRingsCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if showHeartRate {
                    NavigationLink(destination: HeartRateView()) {
                        heartRateCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if showBloodGlucose {
                    NavigationLink(destination: BloodGlucoseView()) {
                        bloodGlucoseCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if showBloodPressure {
                    NavigationLink(destination: BloodPressureView()) {
                        bloodPressureCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if showSpO2 {
                    NavigationLink(destination: SpO2View()) {
                        spo2Card
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if showWeight {
                    NavigationLink(destination: WeightTrackerView()) {
                        weightCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Heart Rate Card
    var heartRateCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(latestHeartRate))")
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
                        let x = width * Double(i) / Double(points.count - 1)
                        let y = height * (1 - points[i])
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    // Close the path to bottom right
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.368, green: 0.553, blue: 0.372).opacity(0.3),
                            Color(red: 0.368, green: 0.553, blue: 0.372).opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 120, height: 60)
                
                // Line on top
                Path { path in
                    let width = 120.0
                    let height = 60.0
                    let points = [0.3, 0.5, 0.2, 0.7, 0.4, 0.8, 0.6, 0.3, 0.5, 0.4, 0.6, 0.2]
                    
                    path.move(to: CGPoint(x: 0, y: height * (1 - points[0])))
                    
                    for i in 1..<points.count {
                        let x = width * Double(i) / Double(points.count - 1)
                        let y = height * (1 - points[i])
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color(red: 0.368, green: 0.553, blue: 0.372), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 120, height: 60)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Blood Glucose Card
    var bloodGlucoseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Blood Glucose")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            Spacer()
            
            if latestBloodGlucose > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(latestBloodGlucose))")
                        .font(.custom("Noto Sans", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                    Text("mg/dL")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
            } else {
                Text("View your blood glucose data and trends")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Blood Pressure Card
    var bloodPressureCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Blood Pressure")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            Spacer()
            
            if let bp = latestBloodPressure {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(bp.systolic)/\(bp.diastolic)")
                        .font(.custom("Noto Sans", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                    Text("mmHg")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
            } else {
                Text("View your blood pressure data and trends")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - SpO2 Card
    var spo2Card: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SpO2")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            Spacer()
            
            if latestSpO2 > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(latestSpO2))")
                        .font(.custom("Noto Sans", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                    Text("%")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
            } else {
                Text("View your SpO2 data and trends")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Weight Card
    var weightCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight")
                .font(.custom("Noto Sans", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            Spacer()
            
            if latestWeight > 0 {
                // Get weight unit from onboarding
                let weightUnit = UserDefaults.standard.string(forKey: "weightUnit") ?? "kg"
                let displayWeight = weightUnit == "lbs" ? latestWeight * 2.20462 : latestWeight
                let unitText = weightUnit == "lbs" ? "lbs" : "kg"
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", displayWeight))
                        .font(.custom("Noto Sans", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                    Text(unitText)
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
            } else {
                Text("View your weight data and trends")
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Health Highlights Section
    var healthHighlightsSection: some View {
        let cardCount = 3
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Health highlights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            // Custom stacked carousel of highlights cards
            GeometryReader { geo in
                let width = geo.size.width
                
                ZStack {
                    // Center card is the current index; neighbours are smaller and behind.
                    ForEach(0..<cardCount, id: \.self) { index in
                        let offsetIndex = index - healthHighlightsCurrentIndex
                        let isCenter = offsetIndex == 0
                        
                        // Only show up to one neighbour on each side in view
                        if abs(offsetIndex) <= 1 {
                            let baseX: CGFloat = CGFloat(offsetIndex) * (width * 0.35)
                            let scale: CGFloat = isCenter ? 1.0 : 0.9
                            let opacity: Double = isCenter ? 1.0 : 0.7
                            let shadowOpacity: Double = isCenter ? 0.12 : 0.06
                            let shadowRadius: CGFloat = isCenter ? 16 : 10
                            
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .frame(width: width * 0.72, height: 120)
                                .overlay(
                                    Text("Highlight \(index + 1)")
                                        .font(.custom("Noto Sans", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.19, green: 0.21, blue: 0.24))
                                )
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .shadow(color: Color.black.opacity(shadowOpacity),
                                        radius: shadowRadius,
                                        x: 0,
                                        y: 8)
                                .offset(x: baseX)
                                .zIndex(isCenter ? 2 : 1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 40
                            if value.translation.width < -threshold && healthHighlightsCurrentIndex < cardCount - 1 {
                                // Swipe left -> next
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    healthHighlightsCurrentIndex += 1
                                }
                            } else if value.translation.width > threshold && healthHighlightsCurrentIndex > 0 {
                                // Swipe right -> previous
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    healthHighlightsCurrentIndex -= 1
                                }
                            }
                        }
                )
            }
            .frame(height: 140)
            
            // Carousel progress bar for the Health Highlights section
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<cardCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == healthHighlightsCurrentIndex ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.5))
                            .frame(width: index == healthHighlightsCurrentIndex ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: healthHighlightsCurrentIndex)
                    }
                }
                Spacer()
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
            
            if medications.isEmpty {
                VStack(spacing: 8) {
                    Text("No medications logged")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            } else {
                // Medication card carousel, where each card display each medicine and status of either taking or skipping that medicine
                TabView(selection: $medicationCurrentIndex) {
                    ForEach(medications.indices, id: \.self) { index in
                        medicationCard(medication: medications[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 100)
                
                // Carousel progress bar for the Medication section
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(medications.indices, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index == medicationCurrentIndex ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.5))
                                .frame(width: index == medicationCurrentIndex ? 24 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: medicationCurrentIndex)
                        }
                    }
                    Spacer()
                }
            }
            
            // Medication Reminders and Adherence section
            HStack(spacing: 12) {
                // Medication Reminders card
                NavigationLink(destination: MedicationLogView()) {
                    remindersCard
                }
                .buttonStyle(PlainButtonStyle())
                
                // Medication Adherence card
                NavigationLink(destination: MedicationLogView()) {
                    adherenceCard
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Medication Card
    func medicationCard(medication: Medication) -> some View {
        HStack {
            // Medication name and instructions to take the medicines
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.custom("Noto Sans", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                Text(medication.instructions)
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
            }
            
            Spacer()
            
            // Medication Skipped and Medication Taken buttons
            HStack(spacing: 8) {
                Button("Skipped") {
                    // Skip action
                }
                .font(.custom("Noto Sans", size: 14))
                .frame(width: 60)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.690, green: 0.698, blue: 0.764), lineWidth: 1)
                )
                .foregroundColor(Color(red: 0.690, green: 0.698, blue: 0.764))
                .cornerRadius(8)
                
                Button("Taken") {
                    // Taken action
                }
                .font(.custom("Noto Sans", size: 14))
                .frame(width: 60)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.690, green: 0.698, blue: 0.764), lineWidth: 1)
                )
                .foregroundColor(Color(red: 0.690, green: 0.698, blue: 0.764))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
    
    // MARK: - Reminders Card
    var remindersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Reminders Card subheading
            Text("Reminders")
                .font(.custom("Noto Sans", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.404, green: 0.420, blue: 0.455))
                .padding(.top, 10)
            
            // Display upcoming medication reminders
            VStack(alignment: .leading, spacing: 16) {
                if upcomingReminders.isEmpty {
                    Text("No upcoming reminders")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                } else {
                    ForEach(Array(upcomingReminders.prefix(2).enumerated()), id: \.offset) { index, reminder in
                        HStack {
                            Image(systemName: index == 0 ? "pills.fill" : "clock.fill")
                                .foregroundColor(Color(red: 0.690, green: 0.698, blue: 0.764))
                                .font(.system(size: 14))
                            Text("\(reminder.name), \(formatReminderTime(reminder.time))")
                                .font(.custom("Noto Sans", size: 14))
                                .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Adherence Card
    var adherenceCard: some View {
        // Progress ring for display user's medication adherence percentage
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 4)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: min(adherencePercentage, 1.0))
                    .stroke(Color(red: 0.368, green: 0.553, blue: 0.372), lineWidth: 4)
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(adherencePercentage * 100))%")
                    .font(.custom("Noto Sans", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.368, green: 0.553, blue: 0.372))
            }
            .padding(.trailing, 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Adherence")
                    .font(.custom("Noto Sans", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                // Week range
                Text(adherenceWeekRange.isEmpty ? "This week" : adherenceWeekRange)
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                // Current month
                Text(formatCurrentMonth())
                    .font(.custom("Noto Sans", size: 14))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Mood Tracker Section
    var moodTrackerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Your Mood Tracker subheading
            HStack {
                Text("Your Mood Tracker")
                    .font(.custom("Noto Sans", size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
                    .background(Color.white)
                    .cornerRadius(16)
                Spacer()
            }
            
            // Showcase the user's mood data
            NavigationLink(destination: MoodTrackerView()) {
                VStack(alignment: .leading, spacing: 4) {
                    // Add contents of mood tracker data here!
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 120)
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Load Metrics from API
    private func loadMetrics() {
        guard !isLoadingMetrics else { return }
        isLoadingMetrics = true
        
        Task {
            do {
                // Load medications from onboarding
                let onboarding = try await onboardingService.getOnboarding()
                let onboardingMedications = onboarding.medications ?? []
                await MainActor.run {
                    medications = (onboarding.medications ?? []).map { med in
                        Medication(
                            name: med.name,
                            instructions: "Instructions for intake", // Placeholder as API doesn't support this yet
                            time: "9:00 AM" // Default time
                        )
                    }
                }
                
                // Load latest metrics for each type
                let calendar = Calendar.current
                let endDate = Date()
                let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
                
                // Heart Rate
                if showHeartRate {
                    let response = try await metricsService.listMetrics(
                        metricType: .heartRate,
                        startDate: startDate,
                        endDate: endDate,
                        pageSize: 1
                    )
                    if let latest = response.metrics.first,
                       let hr = latest.extractHeartRate() {
                        await MainActor.run {
                            latestHeartRate = Double(hr.bpm)
                        }
                    }
                }
                
                // Blood Pressure
                if showBloodPressure {
                    let response = try await metricsService.listMetrics(
                        metricType: .bloodPressure,
                        startDate: startDate,
                        endDate: endDate,
                        pageSize: 1
                    )
                    if let latest = response.metrics.first,
                       let bp = latest.extractBloodPressure() {
                        await MainActor.run {
                            latestBloodPressure = BloodPressureRecord(
                                date: latest.measuredAt,
                                systolic: bp.systolic,
                                diastolic: bp.diastolic,
                                pulse: bp.pulse ?? 0
                            )
                        }
                    }
                }
                
                // Blood Glucose
                if showBloodGlucose {
                    let response = try await metricsService.listMetrics(
                        metricType: .bloodGlucose,
                        startDate: startDate,
                        endDate: endDate,
                        pageSize: 1
                    )
                    if let latest = response.metrics.first,
                       let bg = latest.extractBloodGlucose() {
                        await MainActor.run {
                            latestBloodGlucose = bg.value
                        }
                    }
                }
                
                // SpO2
                if showSpO2 {
                    let response = try await metricsService.listMetrics(
                        metricType: .spo2,
                        startDate: startDate,
                        endDate: endDate,
                        pageSize: 1
                    )
                    if let latest = response.metrics.first,
                       let spo2 = latest.extractSpO2() {
                        await MainActor.run {
                            latestSpO2 = spo2.value
                        }
                    }
                }
                
                // Weight
                if showWeight {
                    let response = try await metricsService.listMetrics(
                        metricType: .weight,
                        startDate: startDate,
                        endDate: endDate,
                        pageSize: 1
                    )
                    if let latest = response.metrics.first,
                       let weight = latest.extractWeight() {
                        await MainActor.run {
                            latestWeight = weight.weight
                        }
                    }
                }
                
                // Mood
                if showMoodTracker {
                    let response = try await metricsService.listMetrics(
                        metricType: .energyMood,
                        startDate: startDate,
                        endDate: endDate,
                        pageSize: 1
                    )
                    if let latest = response.metrics.first,
                       let mood = latest.extractEnergyMood() {
                        await MainActor.run {
                            latestMood = mood
                        }
                    }
                }
                
                // Medication logs (for reminders and adherence cards)
                if showMedicationLog {
                    let calendar = Calendar.current
                    let now = Date()
                    
                    // Get current week start (Monday)
                    let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
                    let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
                    
                    // Fetch taken medication logs for the current week and near future.
                    // The app treats existence of a medication metric at a scheduled slot as "taken".
                    let futureDate = calendar.date(byAdding: .day, value: 7, to: now) ?? now
                    let medicationResponse = try await metricsService.listMetrics(
                        metricType: .medication,
                        startDate: weekStart,
                        endDate: futureDate,
                        pageSize: 100
                    )
                    
                    await MainActor.run {
                        // Helper to create a stable key for a scheduled slot.
                        func slotKey(name: String, scheduledTime: Date) -> String {
                            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledTime)
                            let y = comps.year ?? 0
                            let m = comps.month ?? 0
                            let d = comps.day ?? 0
                            let h = comps.hour ?? 0
                            let min = comps.minute ?? 0
                            return "\(name.lowercased())|\(y)-\(m)-\(d)|\(h):\(min)"
                        }
                        
                        // Build a set of taken slots from API.
                        var takenSlots = Set<String>()
                        for metric in medicationResponse.metrics {
                            if let med = metric.extractMedication() {
                                takenSlots.insert(slotKey(name: med.name, scheduledTime: metric.measuredAt))
                            }
                        }
                        
                        // Build scheduled slots locally (9AM + 3PM), then compute reminders/adherence.
                        let scheduledHours = [9, 15]
                        
                        var reminders: [(name: String, time: Date)] = []
                        var totalScheduled = 0
                        var totalTaken = 0
                        
                        if !onboardingMedications.isEmpty {
                            var day = calendar.startOfDay(for: weekStart)
                            let endDay = calendar.startOfDay(for: futureDate)
                            
                            while day <= endDay {
                                for hour in scheduledHours {
                                    guard let scheduledTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day) else { continue }
                                    
                                    for med in onboardingMedications {
                                        let key = slotKey(name: med.name, scheduledTime: scheduledTime)
                                        let isTaken = takenSlots.contains(key)
                                        
                                        // Upcoming reminder: scheduled in future AND not taken
                                        if scheduledTime > now && !isTaken {
                                            reminders.append((name: med.name, time: scheduledTime))
                                        }
                                        
                                        // Adherence: count scheduled slots in this week up to "now"
                                        if scheduledTime >= weekStart && scheduledTime < weekEnd && scheduledTime <= now {
                                            totalScheduled += 1
                                            if isTaken { totalTaken += 1 }
                                        }
                                    }
                                }
                                
                                day = calendar.date(byAdding: .day, value: 1, to: day) ?? day
                            }
                        }
                        
                        reminders.sort { $0.time < $1.time }
                        upcomingReminders = Array(reminders.prefix(2))
                        
                        adherencePercentage = totalScheduled > 0 ? Double(totalTaken) / Double(totalScheduled) : 0.0
                        
                        // Format week range
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "d"
                        let startStr = dateFormatter.string(from: weekStart)
                        dateFormatter.dateFormat = "d"
                        let endStr = dateFormatter.string(from: calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart)
                        adherenceWeekRange = "\(startStr) to \(endStr)"
                    }
                }
                
                await MainActor.run {
                    isLoadingMetrics = false
                }
            } catch {
                await MainActor.run {
                    isLoadingMetrics = false
                }
                print("⚠️ Failed to load metrics: \(error)")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func formatReminderTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
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
    
    private func loadNotificationSettings() {
        // Load notification settings from UserDefaults
        // Set defaults if not set
        if UserDefaults.standard.object(forKey: "showHeartRate") == nil {
            UserDefaults.standard.set(true, forKey: "showHeartRate")
        }
        if UserDefaults.standard.object(forKey: "showStepsActivity") == nil {
            UserDefaults.standard.set(true, forKey: "showStepsActivity")
        }
        if UserDefaults.standard.object(forKey: "showBloodPressure") == nil {
            UserDefaults.standard.set(true, forKey: "showBloodPressure")
        }
        if UserDefaults.standard.object(forKey: "showBloodGlucose") == nil {
            UserDefaults.standard.set(true, forKey: "showBloodGlucose")
        }
        if UserDefaults.standard.object(forKey: "showSpO2") == nil {
            UserDefaults.standard.set(true, forKey: "showSpO2")
        }
        if UserDefaults.standard.object(forKey: "showWeight") == nil {
            UserDefaults.standard.set(true, forKey: "showWeight")
        }
        if UserDefaults.standard.object(forKey: "showMoodTracker") == nil {
            UserDefaults.standard.set(true, forKey: "showMoodTracker")
        }
        if UserDefaults.standard.object(forKey: "showMedicationLog") == nil {
            UserDefaults.standard.set(true, forKey: "showMedicationLog")
        }
        
        // Update state variables
        showHeartRate = UserDefaults.standard.bool(forKey: "showHeartRate")
        showStepsActivity = UserDefaults.standard.bool(forKey: "showStepsActivity")
        showBloodPressure = UserDefaults.standard.bool(forKey: "showBloodPressure")
        showBloodGlucose = UserDefaults.standard.bool(forKey: "showBloodGlucose")
        showSpO2 = UserDefaults.standard.bool(forKey: "showSpO2")
        showWeight = UserDefaults.standard.bool(forKey: "showWeight")
        showMoodTracker = UserDefaults.standard.bool(forKey: "showMoodTracker")
        showMedicationLog = UserDefaults.standard.bool(forKey: "showMedicationLog")
    }
    
    private func hideFloatingMenu() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            showingAddModal = false
        }
    }
}

// Floating action menu
struct FloatingActionMenu: View {
    let actionTapped: (FloatingActionType) -> Void
    let closeTapped: () -> Void
    
    private let buttonWidth: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 18) {
            ForEach(FloatingActionType.allCases, id: \.self) { action in
                Button {
                    actionTapped(action)
                } label: {
                    FloatingActionMenuButton(action: action, width: buttonWidth)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: closeTapped) {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(red: 0.02, green: 0.33, blue: 0.18))
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
            }
        }
    }
}

struct FloatingActionMenuButton: View {
    let action: FloatingActionType
    let width: CGFloat
    
    var body: some View {
        VStack(spacing: 14) {
            Image(action.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(Color(red: 0.02, green: 0.33, blue: 0.18))
            
            let words = action.title.split(separator: " ").map(String.init)
            VStack(spacing: 2) {
                ForEach(words, id: \.self) { word in
                    Text(word)
                        .font(.custom("Noto Sans", size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.19, green: 0.21, blue: 0.24))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 0)
        .frame(width: width, alignment: .center)
        .background(Color.white)
        .cornerRadius(26)
        .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
    }
}

enum FloatingActionType: CaseIterable {
    case inputWeight
    case inputMood
    case addMedication
    
    var title: String {
        switch self {
        case .inputWeight:
            return "Input Weight"
        case .inputMood:
            return "Input Mood"
        case .addMedication:
            return "Add Medication"
        }
    }
    
    var iconName: String {
        switch self {
        case .inputWeight:
            return "Input Weight"
        case .inputMood:
            return "Input Mood"
        case .addMedication:
            return "Input Medication icon"
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

// Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
