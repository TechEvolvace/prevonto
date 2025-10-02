import SwiftUI

struct ContentView: View {
    @State private var stepCount: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    @State private var heartRate: Double = 60
    @State private var authorizationStatus: String = "Not Requested"
    @State private var showingQuickActions = false
    
    let healthKitManager = HealthKitManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Quick Health Snapshot
                    quickHealthSnapshot
                    
                    // Health Highlights Section
                    healthHighlightsSection
                    
                    // Medication Section
                    medicationSection
                    
                    // Mood Tracker Section
                    moodTrackerSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(UIColor.systemBackground))
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
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("This month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    // Search action
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Button(action: {
                    showingQuickActions = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 25)
    }
    
    // MARK: - Quick Health Snapshot
    var quickHealthSnapshot: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Health Snapshot")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                // Heart Rate Ring
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.6)],
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    Text("Almost there!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Heart Rate Details
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Int(heartRate))bpm")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Avg Heart Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Mini chart placeholder
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .green.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 40)
                        .overlay(
                            // Simple wave pattern
                            Path { path in
                                let width = 120.0
                                let height = 40.0
                                path.move(to: CGPoint(x: 0, y: height/2))
                                for x in stride(from: 0, to: width, by: 2) {
                                    let y = height/2 + 10 * sin(x * 0.1)
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                            .stroke(Color.green, lineWidth: 2)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.bottom, 25)
    }
    
    // MARK: - Health Highlights Section
    var healthHighlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health highlights")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Placeholder cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.tertiarySystemBackground))
                            .frame(width: 160, height: 100)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding(.bottom, 25)
    }
    
    // MARK: - Medication Section
    var medicationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your medication")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Medication")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("Instructions for intake")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button("Skipped") {
                            // Skip action
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.secondary)
                        .cornerRadius(6)
                        
                        Button("Taken") {
                            // Taken action
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                    }
                }
                
                // Reminders
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reminders")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.orange)
                        Text("Medicine, 10:00 AM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.red)
                        Text("Medicine, 11:00 AM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        
                        // Adherence circle
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                                    .frame(width: 30, height: 30)
                                
                                Circle()
                                    .trim(from: 0, to: 0.73)
                                    .stroke(Color.green, lineWidth: 4)
                                    .frame(width: 30, height: 30)
                                    .rotationEffect(.degrees(-90))
                                
                                Text("73%")
                                    .font(.system(size: 8))
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Adherence")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("14 to 21")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("May 2025")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.bottom, 25)
    }
    
    // MARK: - Mood Tracker Section
    var moodTrackerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Mood Tracker")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showingQuickActions = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            
            // Placeholder for mood content
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemBackground))
                .frame(height: 60)
        }
        .padding(.bottom, 25)
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

// MARK: - Quick Actions Modal
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

// MARK: - Quick Action Button Components
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
