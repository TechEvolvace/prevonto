// Controlling the animation shown for displaying the quote in the Sign Up page
import SwiftUI
import Combine

struct AnimatedQuoteView: View {
    let quotes: [String]
    
    @State private var currentQuoteIndex: Int
    @State private var animateOut = false
    @State private var timerCancellable: AnyCancellable? = nil
    
    init(quotes: [String]) {
        self.quotes = quotes
        // Initialize with a random quote index
        _currentQuoteIndex = State(initialValue: Int.random(in: 0..<quotes.count))
    }
    
    var body: some View {
        Text(quotes[currentQuoteIndex])
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .offset(y: animateOut ? 20 : 0)
            .opacity(animateOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.5), value: animateOut)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timerCancellable?.cancel()
            }
    }
    
    func startTimer() {
        timerCancellable = Timer.publish(every: 8, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                // Animate current quote out
                withAnimation {
                    animateOut = true
                }
                
                // After the animation out completes, change to a new random quote
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Select a new quote index (ensuring it's different)
                    var newIndex: Int
                    repeat {
                        newIndex = Int.random(in: 0..<quotes.count)
                    } while newIndex == currentQuoteIndex && quotes.count > 1
                    
                    // Update quote and animate in
                    currentQuoteIndex = newIndex
                    withAnimation {
                        animateOut = false
                    }
                }
            }
    }
}
