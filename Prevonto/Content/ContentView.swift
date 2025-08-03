import SwiftUI

struct ContentView: View {
    @State private var stepCount: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    @State private var heartRate: Double = 0
    @State private var authorizationStatus: String = "Not Requested"
    let healthKitManager = HealthKitManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Dashboard Title
                    Text("Health Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Steps Card
                    VStack {
                        Text("Today's Steps")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(Int(stepCount))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    // Additional Metrics Cards
                    HStack(spacing: 20) {
                        // Calories Card
                        VStack {
                            Text("Calories")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(Int(calories))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        
                        // Distance Card
                        VStack {
                            Text("Distance")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(String(format: "%.2f km", distance))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.pink]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    
                    // Heart Rate Card
                    VStack {
                        Text("Avg Heart Rate")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(heartRate > 0 ? String(format: "%.0f BPM", heartRate) : "-- BPM")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red, Color.orange]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    // HealthKit Authorization Button
                    Button(action: {
                        healthKitManager.requestAuthorization { success, error in
                            if success {
                                authorizationStatus = "Authorized"
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
                    }) {
                        Text("Request HealthKit Authorization")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Text("Authorization Status: \(authorizationStatus)")
                        .font(.subheadline)
                        .foregroundColor(authorizationStatus == "Authorized" ? .green : .red)
                        .padding(.bottom)
                    
                    // Navigation Buttons
                    VStack(spacing: 12) {

                        NavigationLink("Weight Display") {
                            WeightTrackerView()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink("SpO2 Display") {
                            SpO2View()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink("Mood Tracker") {
                            MoodTrackerView()
                        }
                        .buttonStyle(.borderedProminent)

                        NavigationLink("Steps Details") {
                            StepsDetailsView()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink("Heart Rate") {
                            HeartRateView()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink("Blood Glucose") {
                            BloodGlucoseView()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink("Days Tracked") {
                            DaysTrackedView()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        // Placeholder for future pages
                        NavigationLink("More Coming Soon...") {
                            Text("Future Page")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
