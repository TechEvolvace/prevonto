// Onboarding page 9 out of 9 prompts user for any and all allergies they have
import SwiftUI

struct SymptomsAllergyInputView: View {
    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedAllergyCategory: String? = nil
    @State private var showAllergyDetails = false
    @State private var allergyDetails: Set<String> = []
    @State private var allergyDescription: String = ""
    @State private var showAllSymptoms = false

    let next: () -> Void
    let back: () -> Void
    let step: Int

    let commonSymptoms = ["Cough", "Fever", "Headache", "Flu", "Muscle fatigue", "Shortness of breath", "Sore throat", "Runny nose", "Nausea"]
    let allergyCategories = ["Food", "Indoor", "Seasonal", "Drug", "Skin", "Other"]
    let additionalAllergyTags = ["Dairy", "Gluten", "Soy", "Shellfish", "Nuts"]
    
    private var displayedSymptoms: [String] {
        showAllSymptoms ? commonSymptoms : Array(commonSymptoms.prefix(5))
    }
    
    private var remainingSymptomsCount: Int {
        max(0, commonSymptoms.count - 5)
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
                        TextField("Search", text: .constant(""))
                            .disabled(true)
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

                FlowLayout(tags: allergyCategories, selection: .init(
                    get: { selectedAllergyCategory.map { [$0] } ?? [] },
                    set: { selectedAllergyCategory = $0.first }
                )) {
                    if $0 == "Food" {
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
                    selectedTags: $allergyDetails,
                    description: $allergyDescription,
                    isPresented: $showAllergyDetails
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(1000)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showAllergyDetails)
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

    var body: some View {
        FlexibleView(data: tags, spacing: 8, alignment: .leading) { tag in
            TagPill(label: tag, selected: selection.contains(tag)) {
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
            HStack(spacing: 6) {
                Text(label)
                    .font(.footnote)
                    .foregroundColor(selected ? .white : .gray)
                if selected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .padding(.horizontal, 12)
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
    @Binding var selectedTags: Set<String>
    @Binding var description: String
    @Binding var isPresented: Bool
    @State private var showAllAllergies = false

    let allFoodAllergies = ["Dairy", "Gluten", "Soy", "Shellfish", "Nuts", "Eggs", "Fish", "Peanuts", "Sesame"]
    
    private var displayedAllergies: [String] {
        showAllAllergies ? allFoodAllergies : Array(allFoodAllergies.prefix(5))
    }
    
    private var remainingAllergiesCount: Int {
        max(0, allFoodAllergies.count - 5)
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
                Text("Please add additional details\nregarding your food allergy")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
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
                            
                            // Add +4 button to the last row if needed and there's space (less than 3 items)
                            if rowIndex == rows.count - 1 && !showAllAllergies && remainingAllergiesCount > 0 && row.count < 3 {
                                TagPill(label: "+\(remainingAllergiesCount)", selected: false) {
                                    withAnimation {
                                        showAllAllergies = true
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // If we need to show +4 button but last row is full (3 items), add it on a new row
                    if !rows.isEmpty, let lastRow = rows.last, lastRow.count == 3 && !showAllAllergies && remainingAllergiesCount > 0 {
                        HStack(spacing: 8) {
                            TagPill(label: "+\(remainingAllergiesCount)", selected: false) {
                                withAnimation {
                                    showAllAllergies = true
                                }
                            }
                            Spacer()
                        }
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
            .padding(.horizontal, 24)
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
