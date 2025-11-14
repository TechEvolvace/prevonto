// Onboarding page 3 out of 9 prompts user for their age
import SwiftUI

struct AgeSelectionView: View {
    @State private var selectedAge: Int = 19
    let next: () -> Void
    let back: () -> Void
    let step: Int

    let ageRange = Array(13...100)

    var body: some View {
        OnboardingStepWrapper(step: step, title: "How old are you?") {
            VStack(spacing: 24) {
                // Picker for user to swipe or drag vertically to specific age user choose
                CenteredVerticalAgePicker(ages: ageRange, selectedAge: $selectedAge)
                
                Spacer()

                // Next Button
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
}

// Picker for user to swipe or drag vertically to specific age user choose
struct CenteredVerticalAgePicker: View {
    let ages: [Int]
    @Binding var selectedAge: Int

    let itemHeight: CGFloat = 56
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
        .frame(height: 280)
    }
}

// Display each age number for user to can select
struct AgeRow: View {
    let age: Int
    @Binding var selectedAge: Int
    let centerY: CGFloat
    let itemHeight: CGFloat
    let totalHeight: CGFloat
    
    private let secondaryGreen = Color(red: 0.39, green: 0.59, blue: 0.38)

    var body: some View {
        GeometryReader { geo in
            let itemCenterY = geo.frame(in: .global).midY
            let distance = abs(itemCenterY - centerY)
            let maxDistance: CGFloat = totalHeight * 2.5 // Distance for full fade
            let normalizedDistance = min(distance / maxDistance, 1.0)
            
            // Determine if this is the selected age
            let isSelected = distance < totalHeight / 2
            
            // Dynamic font size based on distance from center
            // Selected: 32pt, Very close: 24pt, Close: 20pt, Medium: 18pt, Far: 16pt
            let fontSize: CGFloat = {
                if isSelected {
                    return 32
                } else if normalizedDistance < 0.2 {
                    return 24
                } else if normalizedDistance < 0.4 {
                    return 20
                } else if normalizedDistance < 0.6 {
                    return 18
                } else {
                    return 16
                }
            }()
            
            // Dynamic opacity based on distance
            let opacity = isSelected ? 1.0 : max(0.3, 1.0 - normalizedDistance * 0.7)
            
            // Dynamic font weight
            let fontWeight: Font.Weight = isSelected ? .bold : (normalizedDistance < 0.3 ? .semibold : .regular)
            
            // Calculate box width based on number of digits (2-digit: 100pt, 3-digit: 120pt)
            let boxWidth: CGFloat = isSelected ? (age >= 100 ? 120 : 100) : 0

            Text("\(age)")
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundColor(isSelected ? .white : .gray.opacity(opacity))
                .padding(.horizontal, isSelected ? 24 : 0)
                .padding(.vertical, isSelected ? 12 : 0)
                .frame(width: isSelected ? boxWidth : nil, height: isSelected ? 56 : itemHeight)
                .background(
                    isSelected ? secondaryGreen : Color.clear
                )
                .cornerRadius(isSelected ? 16 : 0)
                .shadow(color: isSelected ? Color.green.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                .frame(maxWidth: .infinity)
                .onAppear {
                    if isSelected {
                        selectedAge = age
                    }
                }
                .onChange(of: distance) { _ in
                    if isSelected {
                        selectedAge = age
                    }
                }
        }
        .frame(height: itemHeight)
    }
}
