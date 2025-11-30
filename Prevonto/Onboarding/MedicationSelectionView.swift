// Onboarding page 8 out of 10 prompts user for any and all medication they currently take
import SwiftUI

struct MedicationSelectionView: View {
    @State private var selectedMeds: [String] = []
    @State private var searchQuery: String = ""
    @State private var searchResults: [MedicationSearchResult] = []
    @State private var isLoading: Bool = false
    @State private var searchTask: Task<Void, Never>?
    
    @StateObject private var dataManager = OnboardingDataManager.shared
    @StateObject private var authManager = AuthManager.shared

    let next: () -> Void
    let back: () -> Void
    let step: Int

    var body: some View {
        OnboardingStepWrapper(step: step, title: "Which medications are\nyou currently taking?") {
            VStack(spacing: 16) {
                // Search bar
                HStack {
                    TextField("Search (min 2 characters)", text: $searchQuery)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .padding(.trailing, 12)
                                } else {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 12)
                                }
                            }
                        )
                        .onChange(of: searchQuery) { _, newValue in
                            performSearch(query: newValue)
                        }
                }

                // Medication search result list
                if !searchResults.isEmpty {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(searchResults, id: \.name) { result in
                                let isSelected = selectedMeds.contains(result.name)
                                
                                Button(action: {
                                    toggleSelection(for: result.name)
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.name)
                                                .foregroundColor(isSelected ? .white : .primary)
                                                .fontWeight(.medium)
                                            if let genericName = result.genericName, genericName != result.name {
                                                Text(genericName)
                                                    .font(.caption)
                                                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                                            }
                                        }
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
                                                    .foregroundColor(Color.secondaryGreen)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(isSelected ? Color.secondaryGreen : Color.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Divider between items (except last)
                                if result.name != searchResults.last?.name {
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
                } else if searchQuery.count >= 2 && !isLoading {
                    Text("No medications found")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding()
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
                    saveMedications()
                    next()
                } label: {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryGreen)
                        .cornerRadius(12)
                }
            }
        }
        .onAppear {
            // Load saved medications if any
            if !dataManager.medications.isEmpty {
                selectedMeds = dataManager.medications.map { $0.name }
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
    
    private func performSearch(query: String) {
        // Cancel previous search task
        searchTask?.cancel()
        
        // Clear results if query is too short
        guard query.count >= 2 else {
            searchResults = []
            return
        }
        
        // Debounce search - wait 300ms after user stops typing
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            guard !Task.isCancelled, query.count >= 2 else { return }
            
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let response = try await MedicationService.shared.searchMedications(query: query)
                
                await MainActor.run {
                    if !Task.isCancelled {
                        searchResults = response.results
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    if !Task.isCancelled {
                        searchResults = []
                        isLoading = false
                    }
                }
            }
        }
    }
    
    private func saveMedications() {
        // Convert selected medication names to OnboardingMedicationEntry format
        // Since onboarding doesn't collect dosage/frequency, use nil
        dataManager.medications = selectedMeds.map { name in
            OnboardingMedicationEntry(
                name: name,
                dosage: nil,
                frequency: nil
            )
        }
    }
}
