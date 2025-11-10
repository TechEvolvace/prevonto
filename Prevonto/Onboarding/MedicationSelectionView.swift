// Onboarding page 8 out of 9 prompts user for any and all medication they currently take
import SwiftUI

struct MedicationSelectionView: View {
    @State private var selectedMeds: [String] = []
    @State private var searchQuery: String = ""

    let next: () -> Void
    let back: () -> Void
    let step: Int

    let allMedications = [
        "Abilify", "Abilify Maintena", "Abiraterone", "Acetaminophen",
        "Actemra", "Aceon", "Accutane", "Acetasol HC", "Aspirin", "Ibuprofen", "Xanax", "Zoloft"
    ]

    var filteredMedications: [String] {
        if searchQuery.isEmpty {
            return []
        } else {
            return allMedications.filter { $0.lowercased().contains(searchQuery.lowercased()) }
        }
    }

    var body: some View {
        OnboardingStepWrapper(step: step, title: "Which medications are\nyou currently taking?") {
            VStack(spacing: 16) {
                // Search bar
                HStack {
                    TextField("Search", text: $searchQuery)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 12)
                            }
                        )
                }

                // Medication search result list
                if !filteredMedications.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredMedications, id: \.self) { med in
                                let isSelected = selectedMeds.contains(med)
                                
                                Button(action: {
                                    toggleSelection(for: med)
                                }) {
                                    HStack {
                                        Text(med)
                                            .foregroundColor(isSelected ? .white : .primary)
                                        Spacer()
                                        // Rounded checkbox
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(isSelected ? Color.white : Color.white)
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1.5)
                                                )
                                            
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.38))
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(isSelected ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Divider between items (except last)
                                if med != filteredMedications.last {
                                    Divider()
                                        .padding(.leading)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .frame(maxHeight: 400)
                }

                // Selected chips
                if !selectedMeds.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected:")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedMeds, id: \.self) { med in
                                    HStack(spacing: 4) {
                                        Text(med)
                                            .font(.footnote)
                                        Image(systemName: "xmark.circle.fill")
                                            .onTapGesture {
                                                selectedMeds.removeAll { $0 == med }
                                            }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Next button
                Button {
                    next()
                } label: {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.01, green: 0.33, blue: 0.18))
                        .cornerRadius(12)
                }
            }
        }
    }

    private func toggleSelection(for medication: String) {
        if selectedMeds.contains(medication) {
            selectedMeds.removeAll { $0 == medication }
        } else {
            selectedMeds.append(medication)
        }
    }
}
