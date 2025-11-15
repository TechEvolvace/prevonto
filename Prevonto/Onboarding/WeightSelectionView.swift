// Onboarding page 2 out of 9 prompts user for their weight
import SwiftUI

struct WeightSelectionView: View {
    @State private var selectedUnit: String = "lbs"
    @State private var selectedWeight: Int = 140

    let lbRange = Array(0...500)
    let kgRange = Array(0...227)

    let next: () -> Void
    let back: () -> Void
    let step: Int

    // Keep track of current selected weight unit
    var currentRange: [Int] {
        selectedUnit == "lbs" ? lbRange : kgRange
    }

    var body: some View {
        OnboardingStepWrapper(step: step, title: "What is your weight?") {
            VStack(spacing: 24) {
                // Weight unit conversion between the 2 weight unit types
                HStack(spacing: 32) {
                    // kg converted to lbs when lbs button is selected
                    UnitButton(title: "lbs", selected: $selectedUnit) {
                        let converted = Int(Double(selectedWeight) * 2.205)
                        selectedWeight = min(max(converted, lbRange.first ?? 0), lbRange.last ?? 500)
                    }
                    // lbs converted to kg when kg button is selected
                    UnitButton(title: "kg", selected: $selectedUnit) {
                        let converted = Int(Double(selectedWeight) * 0.45359237)
                        selectedWeight = min(max(converted, kgRange.first ?? 0), kgRange.last ?? 227)
                    }
                }

                // Display weight amount in current unit
                HStack(spacing: 8) {
                    Text("\(selectedWeight)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.38))
                    Text(selectedUnit)
                        .foregroundColor(.gray)
                        .font(.title3)
                }

                // Picker for user to swipe or drag to correct weight
                WeightPickerView(values: currentRange, selected: $selectedWeight, unit: selectedUnit)
                
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
}

// Picker for user to swipe or drag to correct weights
struct WeightPickerView: View {
    let values: [Int]
    @Binding var selected: Int
    let unit: String // Track unit to detect when it changes

    let itemWidth: CGFloat = 40
    let spacing: CGFloat = 8

    @State private var scrollOffset: CGFloat = 0.0
    @State private var scrollViewWidth: CGFloat = 0.0

    var body: some View {
        GeometryReader { geo in
            let totalItemWidth = itemWidth + spacing
            let horizontalPadding = (geo.size.width - itemWidth) / 2

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(values, id: \.self) { val in
                            GeometryReader { itemGeo in
                                let center = itemGeo.frame(in: .global).midX
                                let screenCenter = geo.frame(in: .global).midX
                                let distance = abs(center - screenCenter)

                                let isSelected = distance < totalItemWidth / 2

                                Color.clear
                                    .onAppear {
                                        if isSelected {
                                            selected = val
                                        }
                                    }
                                    .onChange(of: distance) {
                                        if isSelected {
                                            selected = val
                                        }
                                    }

                                VStack(spacing: 6) {
                                    Rectangle()
                                        .frame(width: 2, height: val % 10 == 0 ? 32 : val % 5 == 0 ? 32 : 24)
                                        .foregroundColor(isSelected ? Color(red: 0.39, green: 0.59, blue: 0.38) : val % 5 == 0 ? Color(red: 36/255, green: 42/255, blue: 52/255).opacity(0.6) : .gray.opacity(0.3))
                                        .padding(.top, val % 10 == 0 ? 0 : val % 5 == 0 ? 4 : 8)

                                    if val % 10 == 0 {
                                        Text("\(val)")
                                            .font(.caption)
                                            .foregroundColor(isSelected ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color(red: 36/255, green: 42/255, blue: 52/255).opacity(0.6))
                                    }
                                }
                                .frame(width: itemWidth)
                            }
                            .frame(width: itemWidth)
                            .id(val)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .onAppear {
                        scrollViewWidth = geo.size.width
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if values.contains(selected) {
                                proxy.scrollTo(selected, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: unit) {
                        // When unit changes, scroll to the converted weight value
                        if values.contains(selected) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(selected, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 16)

            // Vertical slider indicator on weight slider
            VStack(spacing: 4) {
                // Top triangle pointing down
                RoundedTriangle()
                    .rotation(.degrees(180))
                    .frame(width: 8, height: 8)
                RoundedRectangle(cornerRadius: 1)
                    .frame(width: 2, height: 50)
                // Bottom triangle pointing up
                RoundedTriangle()
                    .frame(width: 8, height: 8)
            }
            .foregroundColor(Color(red: 0.39, green: 0.59, blue: 0.38))
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 240)
    }
}


// Rounded triangle shape for slider marker caps of green slider mark
struct RoundedTriangle: Shape {
    var cornerRadius: CGFloat = 1.5
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let curveAmount: CGFloat = 2.0 // Amount of curve for the edges
        
        // Triangle pointing up: top point, bottom left, bottom right
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        
        // Start from top point
        path.move(to: top)
        
        // Curved edge from top to bottom left
        let leftControl = CGPoint(
            x: top.x + (bottomLeft.x - top.x) * 0.5 - curveAmount,
            y: top.y + (bottomLeft.y - top.y) * 0.5 + curveAmount
        )
        path.addQuadCurve(to: bottomLeft, control: leftControl)
        
        // Curved edge from bottom left to bottom right
        let bottomControl = CGPoint(
            x: rect.midX,
            y: rect.maxY + curveAmount
        )
        path.addQuadCurve(to: bottomRight, control: bottomControl)
        
        // Curved edge from bottom right back to top
        let rightControl = CGPoint(
            x: top.x + (bottomRight.x - top.x) * 0.5 + curveAmount,
            y: top.y + (bottomRight.y - top.y) * 0.5 + curveAmount
        )
        path.addQuadCurve(to: top, control: rightControl)
        
        path.closeSubpath()
        return path
    }
}

// Weight Unit toggle selection buttons
struct UnitButton: View {
    let title: String
    @Binding var selected: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: {
            if selected != title {
                selected = title
                onTap()
            }
        }) {
            Text(title)
                .fontWeight(.semibold)
                .font(.title3)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .frame(minWidth: 80)
                .background(selected == title ? Color(red: 0.39, green: 0.59, blue: 0.38) : Color.clear)
                .foregroundColor(selected == title ? .white : .gray)
                .cornerRadius(12)
                .shadow(color: selected == title ? Color.green.opacity(0.25) : .clear, radius: 8, x: 0, y: 4)
        }
    }
}
