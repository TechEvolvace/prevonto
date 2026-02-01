// Analytics Models for API
import Foundation

struct StatisticsResponse: Codable {
    let metricType: MetricType
    let range: String
    let startDate: Date
    let endDate: Date
    let count: Int
    let average: [String: AnyCodable]
    let minimum: [String: AnyCodable]
    let maximum: [String: AnyCodable]
    let median: [String: AnyCodable]
    let stdDeviation: [String: AnyCodable]
    let trend: String?
    let changeFromPrevious: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case metricType = "metric_type"
        case range
        case startDate = "start_date"
        case endDate = "end_date"
        case count
        case average
        case minimum
        case maximum
        case median
        case stdDeviation = "std_deviation"
        case trend
        case changeFromPrevious = "change_from_previous"
    }
}


