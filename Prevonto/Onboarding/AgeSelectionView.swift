// Onboarding page 3 out of 10 prompts user for their age
import SwiftUI

struct AgeSelectionView: View {
    @State private var selectedAge: Int = 19
    let next: () -> Void
    let back: () -> Void
    let step: Int

    let ageRange = Array(1...150)

    var body: some View {
        OnboardingStepWrapper(step: step, title: "How old are you?") {
            VStack(spacing: 24) {
                // Picker for user to swipe or drag vertically to specific age user choose
                CenteredVerticalAgePicker(ages: ageRange, selectedAge: $selectedAge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Next Button
                Button {
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
    }
}

// Picker for user to swipe or drag vertically to specific age user choose
struct CenteredVerticalAgePicker: View {
    let ages: [Int]
    @Binding var selectedAge: Int

    let itemHeight: CGFloat = 80
    let spacing: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let totalHeight = itemHeight + spacing
            let centerY = geo.frame(in: .global).midY

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: spacing) {
                        ForEach(ages, id: \.self) { age in
                            AgeRow(age: age,
                                   selectedAge: $selectedAge,
                                   centerY: centerY,
                                   itemHeight: itemHeight,
                                   totalHeight: totalHeight)
                                .id(age)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, (geo.size.height - itemHeight) / 2)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(selectedAge, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// Display each age number for user to can select
struct AgeRow: View {
    let age: Int
    @Binding var selectedAge: Int
    let centerY: CGFloat
    let itemHeight: CGFloat
    let totalHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
            let itemCenterY = geo.frame(in: .global).midY
            let distance = abs(itemCenterY - centerY)
            let maxDistance: CGFloat = totalHeight * 2.5 // Distance for full fade
            let normalizedDistance = min(distance / maxDistance, 1.0)
            
            // Determine if this is the selected age
            let isSelected = distance < totalHeight / 2
            
            // Dynamic font size based on distance from center, decreasing smoothly as distance increases
            let fontSize: CGFloat = {
                if isSelected {
                    return 52
                } else {
                    // Using normalizedDistance for smooth transition
                    let minSize: CGFloat = 24
                    let maxSize: CGFloat = 52
                    return maxSize - (normalizedDistance * (maxSize - minSize))
                }
            }()
            
            // Dynamic opacity based on distance
            let opacity = isSelected ? 1.0 : max(0.3, 1.0 - normalizedDistance * 0.7)
            
            // Calculate box width based on number of digits
            let boxWidth: CGFloat = isSelected ? (age >= 100 ? 160 : 140) : 0

            Text("\(age)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(isSelected ? .white : .gray.opacity(opacity))
                .frame(width: isSelected ? boxWidth : nil, height: itemHeight)
                .background(
                    isSelected ? Color.secondaryGreen : Color.clear
                )
                .cornerRadius(isSelected ? 16 : 0)
                .shadow(color: isSelected ? Color.green.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                .frame(maxWidth: .infinity)
                .onAppear {
                    if isSelected {
                        selectedAge = age
                    }
                }
                .onChange(of: distance) {
                    if isSelected {
                        selectedAge = age
                    }
                }
        }
        .frame(height: itemHeight)
    }
}
