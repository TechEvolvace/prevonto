// Onboarding page 10 out of 9 prompts user for their preferred metric to see most
import SwiftUI

struct MetricsViewSelection: View {
    @State private var selectedMetrics: Set<String> = []

    let next: () -> Void
    let back: () -> Void
    let step: Int

    struct MetricOption: Identifiable {
        let id = UUID()
        let iconName: String
        let label: String
    }

    let metrics: [MetricOption] = [
        .init(iconName: "Heart Rate icon", label: "Heart Rate"),
        .init(iconName: "Blood Pressure icon", label: "Blood Pressure"),
        .init(iconName: "Blood Glucose icon", label: "Blood Glucose"),
        .init(iconName: "Weight Tracker icon", label: "Weight Tracker"),
        .init(iconName: "Steps and Activity icon", label: "Steps & Activity"),
        .init(iconName: "Medication Log icon", label: "Medication Log"),
        .init(iconName: "Mood Tracker icon", label: "Mood Tracker"),
        .init(iconName: "SpO2 icon", label: "SpO2")
    ]

    var body: some View {
        OnboardingStepWrapper(step: step, title: "What metric would you like to see most?") {
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
                                .fill(selectedMetrics.contains(metric.label) ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.white)
                        )
                        .foregroundColor(selectedMetrics.contains(metric.label) ? .white : Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.6))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
            }

            Spacer()

            Button {
                if !selectedMetrics.isEmpty {
                    next()
                }
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(!selectedMetrics.isEmpty ? .white : .gray)
                    .background(!selectedMetrics.isEmpty ? Color(red: 0.01, green: 0.33, blue: 0.18) : .gray.opacity(0.3))
                    .cornerRadius(12)
            }
        }
    }
}

// To preview Onboarding Page 10, for only developer uses
struct MetricsViewSelection_Previews: PreviewProvider {
    static var previews: some View {
        MetricsViewSelection(
            next: {},
            back: {},
            step: 9
        )
    }
}

