// Weight Tracker page shows the user's weight across week or month.
import Foundation
import SwiftUI
import Charts

// Weight chart
struct WeightChartView: View {
    let data: [(String, Double)]

    var body: some View {
        Chart {
            ForEach(data, id: \.0) { day, value in
                LineMark(
                    x: .value("Day", day),
                    y: .value("Weight", value)
                )
                .foregroundStyle(Color.primaryGreen)
                .interpolationMethod(.monotone)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisValueLabel(horizontalSpacing: 16)
            }
        }
        .chartYScale(domain: 100...120)
        .frame(height: 250)
        .padding(.vertical, 12)
    }
}


class WeightTrackerManager: ObservableObject {
    @Published var entries: [WeightEntry] = []
    private var repository: WeightRepository

    init(repository: WeightRepository = LocalWeightRepository()) {
        self.repository = repository
        self.entries = repository.fetchEntries()
    }

    var averageWeightLb: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { $0.weightLb }.reduce(0, +) / Double(entries.count)
    }

    func addEntry(weight: Double) {
        repository.addEntry(weight: weight)
        entries = repository.fetchEntries()
    }
}



// MARK: - WeightTrackerView
struct WeightTrackerView: View {
    @State private var selectedUnit: String = "Lbs"
    @State private var selectedTab: String = "Week"
    @State private var inputWeight: String = ""
    @ObservedObject private var manager = WeightTrackerManager()
    
    // State for popup
    @State private var showingAddPopup: Bool = false
    @State private var popupSelectedUnit: String = "Lbs"
    @State private var popupSelectedWeight: Int = 0


    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    inputSection
                    averageSection
                    weekMonthToggle
                    graphPlaceholder
                    trendsSection
                    loggedEntriesSection
                }
                .padding(.horizontal)  // Add padding once here
                .padding(.top)
            }
            .background(Color.white)
            .navigationTitle("Weight Full Page")
            .navigationBarTitleDisplayMode(.inline)
            
            // Add for Today Popup Overlay
            if showingAddPopup {
                addForTodayPopup
            }
        }
    }

    // Weight Tracker page header
    private var headerSection: some View {
        VStack(spacing: 4){
            Text("Weight Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.primaryGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Your weight will need to be recorded manually by you on a daily/weekly basis.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.darkGrayText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)
        }
    }

    private var inputSection: some View {
        HStack {
            Text("Current Weight")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryGreen)
            
            Spacer()
            
            Button(action: {
                // Reset to default values
                popupSelectedUnit = "Lbs"
                popupSelectedWeight = 0
                showingAddPopup = true
            }) {
                HStack(spacing: 2) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 16, weight: .regular))
                    Text("Add for Today")
                        .font(.system(size: 16, weight: .regular))
                }
                .foregroundColor(Color.primaryGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.15)
        )
        .padding(.bottom, 8)
    }

    // Displaying the weekly average or monthly averages
    private var averageSection: some View {
        let avg = manager.averageWeightLb
        let displayWeight = selectedUnit == "Kg" ? avg * 0.453592 : avg

        return VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 0) {
                HStack(spacing: 6){
                    Text("\(String(format: "%.1f", displayWeight))")
                        .font(.system(size: 48, weight:  .bold))
                        .foregroundColor(Color.secondaryGreen)
                    
                    Text("\(selectedUnit.lowercased()).")
                        .font(.system(size: 36, weight:  .semibold))
                        .foregroundColor(Color.gray.opacity(0.8))
                        .padding(.top, 8)
                }
                
                Text("\(selectedTab)ly Average")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.gray)
                
                Spacer()
                    .frame(height: 16)

                unitToggle
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 0.15)
            }
        }
    }
    
    // Buttons to toggle between lbs and kg units for weights
    private var unitToggle: some View {
        HStack(spacing: 0) {
            Button(action: { selectedUnit = "Lbs" }) {
                Text("Lb")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(selectedUnit == "Lbs" ? Color.secondaryColor : Color.gray.opacity(0.2))
                    .foregroundColor(selectedUnit == "Lbs" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 8,
                bottomLeadingRadius: 8,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            ))

            Button(action: { selectedUnit = "Kg" }) {
                Text("Kg")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(selectedUnit == "Kg" ? Color.secondaryColor : Color.gray.opacity(0.2))
                    .foregroundColor(selectedUnit == "Kg" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 8,
                topTrailingRadius: 8
            ))
        }
    }

    // Buttons to toggle between Week mode or Month mode
    private var weekMonthToggle: some View {
        HStack {
            Button("Week") {
                selectedTab = "Week"
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(selectedTab == "Week" ? Color.secondaryColor : Color.white)
            .foregroundColor(selectedTab == "Week" ? .white : Color.gray)
            .cornerRadius(8)
            .shadow(color: selectedTab == "Week" ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)

            Button("Month") {
                selectedTab = "Month"
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(selectedTab == "Month" ? Color.secondaryColor : Color.white)
            .foregroundColor(selectedTab == "Month" ? .white : Color.gray)
            .cornerRadius(8)
            .shadow(color: selectedTab == "Month" ? .clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
        }
    }

    private var graphPlaceholder: some View {
        // Card containing the weight chart, with fixed placeholder weight data.
        // Unfortunately, will need to restructure weight data to have dynamic chart for weight data (in lbs vs kg) in Week vs Month mode.
        VStack {
            WeightChartView(data: [
                ("Su", 113),
                ("M", 112),
                ("T", 112.5),
                ("W", 114),
                ("Th", 113),
                ("F", 114),
                ("S", 113)
            ])
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.tintedShadow, radius: 4, x: 0, y: 2)
    }

    // Display trends information from weight data
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trends")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.gray)

            HStack{
                Rectangle()
                    .fill(Color.secondaryGreen)
                    .frame(width: 20, height: 20)
                
                Text("No significant change in weight today—great consistency!")
                    .font(.footnote)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )

            HStack {
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text("This BMI falls outside the typical range. Tracking your health over time can offer helpful insight.")
                        .font(.footnote)
                    Text("Learn more...")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )
        }
    }

    // Logged Entries dropped button to display recent added weight entries
    private var loggedEntriesSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Logged Entries")
                    .font(.headline)
                    .foregroundColor(Color.primaryGreen)
                Spacer()
                Image(systemName: "chevron.down")
            }

            ForEach(manager.entries) { entry in
                HStack {
                    Text(entry.formattedDate)
                        .foregroundStyle(Color.gray)
                    Spacer()
                    Text(String(format: "%.1f", entry.weight(in: selectedUnit)))
                        .foregroundStyle(Color.gray)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3))
        )
    }
    
    // MARK: - Add for Today Popup
    private var addForTodayPopup: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    showingAddPopup = false
                }
            
            // Popup content
            VStack(spacing: 0) {
                // Lb/Kg toggle buttons
                popupUnitToggle
                    .padding(.bottom, 20)
                
                // Display weight amount in current unit
                HStack(spacing: 8) {
                    Text("\(popupSelectedWeight)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color.secondaryGreen)
                    Text(popupSelectedUnit.lowercased())
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                        .offset(y: 8)
                }
                .padding(.bottom, 8)
                
                // Weight picker
                WeightPickerView(
                    values: popupSelectedUnit == "Lbs" ? Array(0...500) : Array(0...227),
                    selected: $popupSelectedWeight,
                    unit: popupSelectedUnit
                )
                .frame(height: 320)
                .padding(.bottom, -200)
                
                // Save button
                Button(action: saveNewWeight) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.primaryGreen)
                        .cornerRadius(10)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
    }
    
    private var popupUnitToggle: some View {
        HStack(spacing: 0) {
            Button(action: {
                if popupSelectedUnit != "Lbs" {
                    let converted = Int(Double(popupSelectedWeight) * 2.205)
                    popupSelectedWeight = min(max(converted, 0), 500)
                    popupSelectedUnit = "Lbs"
                }
            }) {
                Text("Lb")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(popupSelectedUnit == "Lbs" ? Color.secondaryColor : Color.gray.opacity(0.2))
                    .foregroundColor(popupSelectedUnit == "Lbs" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 8,
                bottomLeadingRadius: 8,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            ))
            
            Button(action: {
                if popupSelectedUnit != "Kg" {
                    let converted = Int(Double(popupSelectedWeight) * 0.45359237)
                    popupSelectedWeight = min(max(converted, 0), 227)
                    popupSelectedUnit = "Kg"
                }
            }) {
                Text("Kg")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(popupSelectedUnit == "Kg" ? Color.secondaryColor : Color.gray.opacity(0.2))
                    .foregroundColor(popupSelectedUnit == "Kg" ? .white : .black)
            }
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 8,
                topTrailingRadius: 8
            ))
        }
    }
    
    private func saveNewWeight() {
        // Convert to lbs for storage (since WeightEntry stores in lbs)
        let weightInLbs: Double
        if popupSelectedUnit == "Kg" {
            weightInLbs = Double(popupSelectedWeight) * 2.205
        } else {
            weightInLbs = Double(popupSelectedWeight)
        }
        
        manager.addEntry(weight: weightInLbs)
        showingAddPopup = false
    }
}

// MARK: Some custom-defined colors
private extension Color {
    static let primaryGreen = Color(red: 0.01, green: 0.33, blue: 0.18)
    static let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)
    static let darkGrayText = Color(red: 0.25, green: 0.33, blue: 0.44)
    static let barDefault = Color(red: 0.682, green: 0.698, blue: 0.788)
    static let tintedShadow = Color("Pale Slate Shadow")
}

// To preview Weight Tracker page, for only developer uses
struct WeightTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        WeightTrackerView()
    }
}
