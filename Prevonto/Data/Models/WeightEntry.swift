// Weight data structure
import Foundation

struct WeightEntry: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    let weightLb: Double

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    func weight(in unit: String) -> Double {
        unit == "Kg" ? weightLb * 0.453592 : weightLb
    }
}
