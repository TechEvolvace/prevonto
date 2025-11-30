// Onboarding page 10 out of 10 prompts user for their preferred metric to see most
import SwiftUI

struct MetricsSelectionView: View {
    @StateObject private var dataManager = OnboardingDataManager.shared
    @State private var selectedMetrics: Set<String> = []

    let next: () -> Void
    let back: () -> Void
    let step: Int

    struct MetricOption: Identifiable {
        let id = UUID()
        let iconName: String
        let label: String
        let apiValue: String // API enum value
    }

    // Available metric options user can select in this page mapped to appropriate API values
    let metrics: [MetricOption] = [
        .init(iconName: "Heart Rate icon", label: "Heart Rate", apiValue: "heart_rate"),
        .init(iconName: "Blood Pressure icon", label: "Blood Pressure", apiValue: "blood_pressure"),
        .init(iconName: "Blood Glucose icon", label: "Blood Glucose", apiValue: "blood_glucose"),
        .init(iconName: "Weight Tracker icon", label: "Weight Tracker", apiValue: "weight"),
        .init(iconName: "Steps and Activity icon", label: "Steps & Activity", apiValue: "steps_activity"),
        .init(iconName: "Medication Log icon", label: "Medication Log", apiValue: "medication"),
        .init(iconName: "Mood Tracker icon", label: "Mood Tracker", apiValue: "energy_mood"),
        .init(iconName: "SpO2 icon", label: "SpO2", apiValue: "spo2")
    ]
    
    private func mapLabelsToAPIValues(_ labels: Set<String>) -> [String] {
        return labels.compactMap { label in
            metrics.first(where: { $0.label == label })?.apiValue
        }
    }
    
    private func mapAPIValuesToLabels(_ apiValues: [String]) -> Set<String> {
        return Set(apiValues.compactMap { apiValue in
            metrics.first(where: { $0.apiValue == apiValue })?.label
        })
    }

    var body: some View {
        OnboardingStepWrapper(step: step, title: "What metric would you like to see most?") {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(metrics) { metric in
                        Button(action: {
                            // Handles button selection and deselection
                            if selectedMetrics.contains(metric.label) {
                                // Lets the user deselect their selection
                                selectedMetrics.remove(metric.label)
                            } else {
                                selectedMetrics.insert(metric.label)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Image(metric.iconName)
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(selectedMetrics.contains(metric.label) ? .white : Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.6))
                                        .frame(width: 26, height: 26)
                                        .aspectRatio(contentMode: .fit)
                                    Text(metric.label)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedMetrics.contains(metric.label) ? Color.secondaryGreen : Color.white)
                            )
                            .foregroundColor(selectedMetrics.contains(metric.label) ? .white : Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.6))
                            .shadow(color: Color.neutralShadow, radius: 4, x: 0, y: 2)
                        }
                    }
                }
            }

            Spacer()

            Button {
                if !selectedMetrics.isEmpty {
                    dataManager.preferredMetrics = mapLabelsToAPIValues(selectedMetrics)
                    next()
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(!selectedMetrics.isEmpty ? .white : .gray)
                    .background(!selectedMetrics.isEmpty ? Color.primaryGreen : .gray.opacity(0.3))
                    .cornerRadius(12)
            }
        }
        .onAppear {
            // Load saved preferred metrics if any
            if !dataManager.preferredMetrics.isEmpty {
                selectedMetrics = mapAPIValuesToLabels(dataManager.preferredMetrics)
            }
        }
    }
}

// To preview Onboarding Page 10, for only developer uses
struct MetricsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsSelectionView(
            next: {},
            back: {},
            step: 9
        )
    }
}

