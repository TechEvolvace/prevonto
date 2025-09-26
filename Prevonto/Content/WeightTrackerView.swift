import Foundation
import SwiftUI
import Charts

struct WeightChartView: View {
    let data: [(String, Double)]

    var body: some View {
        Chart {
            ForEach(data, id: \.0) { day, value in
                LineMark(
                    x: .value("Day", day),
                    y: .value("Weight", value)
                )
                .foregroundStyle(Color(red: 0.01, green: 0.33, blue: 0.18)) // Dark green line
                .interpolationMethod(.monotone)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartYScale(domain: 100...120)
        .frame(height: 150)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
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
    @State private var selectedUnit: String = "Lb"
    @State private var selectedTab: String = "Week"
    @State private var inputWeight: String = ""
    @ObservedObject private var manager = WeightTrackerManager()


    var body: some View {
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
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Weight Full Page")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        Text("Weight Tracker")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inputSection: some View {
        HStack {
            TextField("Current Weight", text: $inputWeight)
                .keyboardType(.decimalPad)
                .padding(.vertical, 12)

            Spacer()

            Button(action: {
                if let value = Double(inputWeight) {
                    manager.addEntry(weight: value)
                    inputWeight = ""
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                    Text("Add for Today")
                }
                .font(.subheadline)
                .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3))
        )
    }

    private var averageSection: some View {
        let avg = manager.averageWeightLb
        let displayWeight = selectedUnit == "Kg" ? avg * 0.453592 : avg

        return VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Average")
                .font(.subheadline)
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("\(String(format: "%.1f", displayWeight)) \(selectedUnit.lowercased()).")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.gray)

                unitToggle
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
        }
        .padding(.horizontal) // Padding around the entire section
    }
    private var unitToggle: some View {
        HStack(spacing: 0) {
            Button(action: { selectedUnit = "Lb" }) {
                Text("Lb")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(selectedUnit == "Lb" ? Color.secondaryColor : Color.gray.opacity(0.2))
                    .foregroundColor(selectedUnit == "Lb" ? .white : .black)
            }
            .cornerRadius(6)

            Button(action: { selectedUnit = "Kg" }) {
                Text("Kg")
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background(selectedUnit == "Kg" ? Color.secondaryColor : Color.gray.opacity(0.2))
                    .foregroundColor(selectedUnit == "Kg" ? .white : .black)
            }
            .cornerRadius(6)
        }
    }

    private var weekMonthToggle: some View {
        HStack {
            Button("Week") {
                selectedTab = "Week"
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(selectedTab == "Week" ? Color.secondaryColor : Color.gray.opacity(0.2))
            .foregroundColor(selectedTab == "Week" ? .white : .black)
            .cornerRadius(8)

            Button("Month") {
                selectedTab = "Month"
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(selectedTab == "Month" ? Color.secondaryColor : Color.gray.opacity(0.2))
            .foregroundColor(selectedTab == "Month" ? .white : .black)
            .cornerRadius(8)
        }
    }

    private var graphPlaceholder: some View {
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
        .shadow(radius: 1)
    }

    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trends")
                .font(.headline)
                .foregroundColor(.black)

            HStack {
                Rectangle()
                    .fill(Color(red: 0.39, green: 0.59, blue: 0.38))
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

    private var loggedEntriesSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Logged Entries")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.01, green: 0.33, blue: 0.18))
                Spacer()
                Image(systemName: "chevron.down")
            }

            ForEach(manager.entries) { entry in
                HStack {
                    Text(entry.formattedDate)
                    Spacer()
                    Text(String(format: "%.1f", entry.weight(in: selectedUnit)))
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
}

// MARK: - Preview

struct WeightTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        WeightTrackerView()
    }
}
