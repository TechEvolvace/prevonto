// Onboarding page 9 out of 9 prompts user for any and all allergies they have
import SwiftUI

struct SymptomsAllergyInputView: View {
    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedAllergyCategories: Set<String> = []
    @State private var showAllergyDetails = false
    @State private var currentAllergyType: String = ""
    @State private var foodAllergyDetails: Set<String> = []
    @State private var foodAllergyDescription: String = ""
    @State private var indoorAllergyDetails: Set<String> = []
    @State private var indoorAllergyDescription: String = ""
    @State private var seasonalAllergyDetails: Set<String> = []
    @State private var seasonalAllergyDescription: String = ""
    @State private var drugAllergyDetails: Set<String> = []
    @State private var drugAllergyDescription: String = ""
    @State private var skinAllergyDetails: Set<String> = []
    @State private var skinAllergyDescription: String = ""
    @State private var showAllSymptoms = false
    @State private var searchText: String = ""

    let next: () -> Void
    let back: () -> Void
    let step: Int

    let commonSymptoms = ["Cough", "Fever", "Headache", "Flu", "Muscle fatigue", "Shortness of breath", "Sore throat", "Runny nose", "Nausea"]
    let allergyCategories = ["Food", "Indoor", "Seasonal", "Drug", "Skin", "Other"]
    let additionalAllergyTags = ["Dairy", "Gluten", "Soy", "Shellfish", "Nuts"]
    
    // Filter symptoms based on search text
    private var filteredSymptoms: [String] {
        if searchText.isEmpty {
            return commonSymptoms
        } else {
            return commonSymptoms.filter { symptom in
                symptom.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var displayedSymptoms: [String] {
        // If searching, show all filtered results. Otherwise, respect the showAllSymptoms state
        if !searchText.isEmpty {
            return filteredSymptoms
        } else {
            return showAllSymptoms ? commonSymptoms : Array(commonSymptoms.prefix(5))
        }
    }
    
    private var remainingSymptomsCount: Int {
        if !searchText.isEmpty {
            return 0 // Don't show expand button when searching
        }
        return max(0, commonSymptoms.count - 5)
    }

    var body: some View {
        OnboardingStepWrapper(step: step, title: "Do you have any\nsymptoms or allergies?") {
            VStack(alignment: .leading, spacing: 0) {
                
                VStack(alignment: .leading, spacing: 0){
                    // Symptoms section
                    Text("Symptoms")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)

                    SymptomsFlowLayout(
                        symptoms: displayedSymptoms,
                        selection: $selectedSymptoms,
                        showExpandButton: !showAllSymptoms && remainingSymptomsCount > 0,
                        expandButtonLabel: "+\(remainingSymptomsCount)",
                        onExpand: {
                            withAnimation {
                                showAllSymptoms = true
                            }
                        }
                    )

                    HStack {
                        TextField("Search", text: $searchText)
                            .padding(.vertical, 8)
                            .padding(.leading, 12)
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
                    .frame(height: 44)
                }
                .padding(.bottom, 48)

                // Allergy section
                Text("Allergies")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)

                FlowLayout(tags: allergyCategories, selection: $selectedAllergyCategories) { category in
                    if ["Food", "Indoor", "Seasonal", "Drug", "Skin"].contains(category) && selectedAllergyCategories.contains(category) {
                        // Open the popup for the selected allergy category
                        currentAllergyType = category
                        showAllergyDetails = true
                    }
                }

                Spacer()

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
        .overlay {
            if showAllergyDetails {
                AllergyDetailPopup(
                    allergyType: currentAllergyType,
                    selectedTags: getSelectedTagsBinding(for: currentAllergyType),
                    description: getDescriptionBinding(for: currentAllergyType),
                    isPresented: $showAllergyDetails
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(1000)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showAllergyDetails)
    }
    
    // Helper functions to get the appropriate binding based on allergy type
    private func getSelectedTagsBinding(for allergyType: String) -> Binding<Set<String>> {
        switch allergyType {
        case "Food":
            return $foodAllergyDetails
        case "Indoor":
            return $indoorAllergyDetails
        case "Seasonal":
            return $seasonalAllergyDetails
        case "Drug":
            return $drugAllergyDetails
        case "Skin":
            return $skinAllergyDetails
        default:
            return $foodAllergyDetails
        }
    }
    
    private func getDescriptionBinding(for allergyType: String) -> Binding<String> {
        switch allergyType {
        case "Food":
            return $foodAllergyDescription
        case "Indoor":
            return $indoorAllergyDescription
        case "Seasonal":
            return $seasonalAllergyDescription
        case "Drug":
            return $drugAllergyDescription
        case "Skin":
            return $skinAllergyDescription
        default:
            return $foodAllergyDescription
        }
    }
}

struct SymptomsFlowLayout: View {
    let symptoms: [String]
    @Binding var selection: Set<String>
    let showExpandButton: Bool
    let expandButtonLabel: String
    let onExpand: () -> Void
    
    var body: some View {
        FlexibleViewWithTrailing(
            data: symptoms,
            spacing: 8,
            alignment: .leading,
            trailingView: showExpandButton ? {
                TagPill(label: expandButtonLabel, selected: false, action: onExpand)
            } : nil
        ) { tag in
            TagPill(label: tag, selected: selection.contains(tag)) {
                if selection.contains(tag) {
                    selection.remove(tag)
                } else {
                    selection.insert(tag)
                }
            }
        }
    }
}

struct FlowLayout: View {
    let tags: [String]
    @Binding var selection: Set<String>
    var onTap: ((String) -> Void)? = nil
    
    private func displayLabel(for tag: String) -> String {
        if ["Food", "Indoor", "Seasonal", "Drug", "Skin"].contains(tag) {
            return "\(tag) >"
        }
        return tag
    }

    var body: some View {
        FlexibleView(data: tags, spacing: 8, alignment: .leading) { tag in
            TagPill(label: displayLabel(for: tag), selected: selection.contains(tag)) {
                if selection.contains(tag) {
                    selection.remove(tag)
                } else {
                    selection.insert(tag)
                }
                onTap?(tag)
            }
        }
    }
}


struct TagPill: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.footnote)
                .foregroundColor(selected ? .white : .gray)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(selected ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Popup for allergies
struct AllergyDetailPopup: View {
    let allergyType: String
    @Binding var selectedTags: Set<String>
    @Binding var description: String
    @Binding var isPresented: Bool
    @State private var showAllAllergies = false

    // Allergy lists for each category
    let allFoodAllergies = ["Dairy", "Gluten", "Soy", "Shellfish", "Nuts", "Eggs", "Fish", "Peanuts", "Sesame"]
    let allIndoorAllergies = ["Dust mites", "Mold", "Pet dander", "Cockroaches", "Pollen (indoor)", "Carpet fibers", "Air fresheners", "Cleaning products"]
    let allSeasonalAllergies = ["Tree pollen", "Grass pollen", "Weed pollen", "Ragweed", "Birch", "Oak", "Cedar", "Maple"]
    let allDrugAllergies = ["Penicillin", "Aspirin", "Ibuprofen", "Sulfa drugs", "Antibiotics", "NSAIDs", "Anesthesia", "Vaccines"]
    let allSkinAllergies = ["Latex", "Nickel", "Fragrances", "Cosmetics", "Hair dye", "Detergents", "Soaps", "Rubber"]
    
    private var allergies: [String] {
        switch allergyType {
        case "Food":
            return allFoodAllergies
        case "Indoor":
            return allIndoorAllergies
        case "Seasonal":
            return allSeasonalAllergies
        case "Drug":
            return allDrugAllergies
        case "Skin":
            return allSkinAllergies
        default:
            return allFoodAllergies
        }
    }
    
    private var popupTitle: String {
        switch allergyType {
        case "Food":
            return "Please add additional details\nregarding your food allergy"
        case "Indoor":
            return "Please add additional details\nregarding your indoor allergy"
        case "Seasonal":
            return "Please add additional details\nregarding your seasonal allergy"
        case "Drug":
            return "Please add additional details\nregarding your drug allergy"
        case "Skin":
            return "Please add additional details\nregarding your skin allergy"
        default:
            return "Please add additional details\nregarding your allergy"
        }
    }
    
    private var displayedAllergies: [String] {
        showAllAllergies ? allergies : Array(allergies.prefix(5))
    }
    
    private var remainingAllergiesCount: Int {
        max(0, allergies.count - 5)
    }
    

    var body: some View {
        ZStack {
            // Dimmed background covering entire screen
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // Centered popup
            VStack(spacing: 20) {
                // Title
                Text(popupTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
                
                // Allergy tags in rows of 3
                VStack(alignment: .leading, spacing: 8) {
                    // Create rows of 3 items each
                    let allItems = displayedAllergies
                    let rows = stride(from: 0, to: allItems.count, by: 3).map {
                        Array(allItems[$0..<min($0 + 3, allItems.count)])
                    }
                    
                    ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                        HStack(spacing: 8) {
                            // Display allergies in this row
                            ForEach(row, id: \.self) { tag in
                                TagPill(label: tag, selected: selectedTags.contains(tag)) {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            }
                            
                            // Add +# button, where the # indicates the number of hidden allergies not shown yet.
                            if rowIndex == rows.count - 1 && !showAllAllergies && remainingAllergiesCount > 0 && row.count < 3 {
                                TagPill(label: "+\(remainingAllergiesCount)", selected: false) {
                                    withAnimation {
                                        showAllAllergies = true
                                    }
                                }
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Determine placement of +# button in allergy popup
                    if !rows.isEmpty, let lastRow = rows.last, lastRow.count == 3 && !showAllAllergies && remainingAllergiesCount > 0 {
                        HStack(spacing: 8) {
                            TagPill(label: "+\(remainingAllergiesCount)", selected: false) {
                                withAnimation {
                                    showAllAllergies = true
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Description text area
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .scrollContentBackground(.hidden)
                    
                    if description.isEmpty {
                        Text("Add more description...")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.system(size: 14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                // Save button
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.01, green: 0.33, blue: 0.18))
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 60)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct FlexibleViewWithTrailing<Data: Collection, Content: View, Trailing: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    let trailingView: (() -> Trailing)?

    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading,
         trailingView: (() -> Trailing)? = nil,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
        self.trailingView = trailingView
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var rows: [[Data.Element]] = [[]]

        for item in data {
            let itemView = UIHostingController(rootView: content(item)).view!
            let itemSize = itemView.intrinsicContentSize

            if width + itemSize.width + spacing > geometry.size.width {
                width = 0
                height += itemSize.height + spacing
                rows.append([item])
            } else {
                rows[rows.count - 1].append(item)
            }
            width += itemSize.width + spacing
        }

        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                    // Add trailing view inline with the last row
                    if index == rows.count - 1, let trailingView = trailingView {
                        trailingView()
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        var rows: [[Data.Element]] = [[]]

        for item in data {
            let itemView = UIHostingController(rootView: content(item)).view!
            let itemSize = itemView.intrinsicContentSize

            if width + itemSize.width + spacing > geometry.size.width {
                width = 0
                height += itemSize.height + spacing
                rows.append([item])
            } else {
                rows[rows.count - 1].append(item)
            }
            width += itemSize.width + spacing
        }

        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
}

// To preview Onboarding Page 9, for only developer uses
struct SymptomsAllergyInputView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomsAllergyInputView(
            next: {},
            back: {},
            step: 8
        )
    }
}
