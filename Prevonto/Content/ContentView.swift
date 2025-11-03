// Dashboard page for the Prevonto app
import SwiftUI
import Charts

struct ContentView: View {
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
    
    let healthKitManager = HealthKitManager()
    
    // Sample medication data
    private let medications = [
        Medication(name: "Medication", instructions: "Instructions for intake", time: "10:00 AM"),
        Medication(name: "Ibuprofen", instructions: "Take one tablet with food 3 times a day", time: "6:00 PM"),
        Medication(name: "Vitamin D2", instructions: "Take 1 capsule by mouth once weekly", time: "8:00 AM")
    ]
    
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
                        medicationSection
                        moodTrackerSection
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
                .background(Color.white)
                .navigationBarHidden(true)
                                
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
                                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
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
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                }
                
                // New Settings Button
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
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
            
            // Conditional Health Metrics Display
            HStack(spacing: 16) {
                // Only show activity rings if Steps & Activity is enabled in notifications
                if showStepsActivity {
                    NavigationLink(destination: StepsDetailsView()) {
                        activityRingsCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Only show heart rate if Heart Rate is enabled in notifications
                if showHeartRate {
                    NavigationLink(destination: HeartRateView()) {
                        heartRateCard
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // If both are disabled, show a placeholder
                if !showStepsActivity && !showHeartRate {
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
                    .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
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
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Health Highlights Section
    var healthHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health highlights")
                .font(.custom("Noto Sans", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.36, green: 0.55, blue: 0.37))
            
            // Carousel of cards, where each card contains a specific health summary information for user
            TabView(selection: $healthHighlightsCurrentIndex) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.96, green: 0.97, blue: 0.98))
                        .frame(width: 280, height: 120)
                        .scaleEffect(index == healthHighlightsCurrentIndex ? 1.0 : 0.9)
                        .animation(.easeInOut(duration: 0.3), value: healthHighlightsCurrentIndex)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 140)
            
            // Carousel progress bar for the Health Highlights section
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
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
            
            // Medication card carousel, where each card display each medicine and status of either taking or skipping that medicine
            TabView(selection: $medicationCurrentIndex) {
                ForEach(medications.indices, id: \.self) { index in
                    medicationCard(medication: medications[index])
                        .frame(width: 280)
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
            
            // Medication Reminders and Adherence section
            HStack(spacing: 12) {
                // Medication Reminders card
                remindersCard
                
                // Medication Adherence card
                adherenceCard
            }
        }
    }
    
    // MARK: - Medication Card
    func medicationCard(medication: Medication) -> some View {
        HStack {
            // Medication name and instructions to take the medicine
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
                .background(Color(red: 0.02, green: 0.33, blue: 0.18))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .frame(width: 325)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
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
            
            // Display each medicine user wants a reminder for
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "pills.fill")
                        .foregroundColor(Color(red: 0.690, green: 0.698, blue: 0.764))
                        .font(.system(size: 14))
                    Text("Medicine, 10:00 AM")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(Color(red: 0.690, green: 0.698, blue: 0.764))
                        .font(.system(size: 14))
                    Text("Medicine, 11:00 AM")
                        .font(.custom("Noto Sans", size: 14))
                        .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Adherence Card
    var adherenceCard: some View {
        // Progress ring for display user's medication adherence percentage
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 4)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: 0.73)
                    .stroke(Color(red: 0.368, green: 0.553, blue: 0.372), lineWidth: 4)
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                Text("73%")
                    .font(.custom("Noto Sans", size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.368, green: 0.553, blue: 0.372))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Adherence")
                    .font(.custom("Noto Sans", size: 13))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                // Days of the Week
                Text("21 to 28")
                    .font(.custom("Noto Sans", size: 12))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
                // Display Selected Month
                Text("September 2025")
                    .font(.custom("Noto Sans", size: 12))
                    .foregroundColor(Color(red: 0.40, green: 0.42, blue: 0.46))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
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
            VStack(alignment: .leading, spacing: 4) {
                // Add contents of mood tracker data here!
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 120)
            .padding(16)
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
    
    private func loadNotificationSettings() {
        // Load notification settings from UserDefaults
        // Set defaults if not set
        if UserDefaults.standard.object(forKey: "showHeartRate") == nil {
            UserDefaults.standard.set(true, forKey: "showHeartRate")
        }
        if UserDefaults.standard.object(forKey: "showStepsActivity") == nil {
            UserDefaults.standard.set(true, forKey: "showStepsActivity")
        }
        
        // Update state variables
        showHeartRate = UserDefaults.standard.bool(forKey: "showHeartRate")
        showStepsActivity = UserDefaults.standard.bool(forKey: "showStepsActivity")
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
    
    private let buttonWidth: CGFloat = 150
    
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
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
            }
        }
    }
}

struct FloatingActionMenuButton: View {
    let action: FloatingActionType
    let width: CGFloat
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: action.iconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(red: 0.02, green: 0.33, blue: 0.18))
                .frame(width: 32, height: 32)
            
            Text(action.title)
                .font(.custom("Noto Sans", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.19, green: 0.21, blue: 0.24))
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
            return "scalemass.fill"
        case .inputMood:
            return "face.smiling.fill"
        case .addMedication:
            return "pills.fill"
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
