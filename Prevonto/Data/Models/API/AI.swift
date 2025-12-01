// AI Models for API
import Foundation

enum AnomalySeverity: String, Codable {
    case low
    case medium
    case high
    case critical
}

struct Anomaly: Codable, Identifiable {
    let id: String?
    let metricType: MetricType
    let detectedAt: Date
    let measuredAt: Date
    let value: [String: AnyCodable]
    let expectedRange: [String: AnyCodable]?
    let severity: AnomalySeverity
    let description: String
    let recommendation: String?

    enum CodingKeys: String, CodingKey {
        case id
        case metricType = "metric_type"
        case detectedAt = "detected_at"
        case measuredAt = "measured_at"
        case value
        case expectedRange = "expected_range"
        case severity
        case description
        case recommendation
    }
}

struct Insight: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let insightType: String?
    let metricsInvolved: [MetricType]?
    let generatedAt: Date
    let confidence: Double?
    let actionable: Bool?
    let actionText: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case insightType = "insight_type"
        case metricsInvolved = "metrics_involved"
        case generatedAt = "generated_at"
        case confidence
        case actionable
        case actionText = "action_text"
    }
}

struct DailySummary: Codable {
    let date: Date
    let metricsTracked: [MetricType]
    let insights: [Insight]
    let anomalies: [Anomaly]
    let overallScore: Double?
    let summaryText: String

    enum CodingKeys: String, CodingKey {
        case date
        case metricsTracked = "metrics_tracked"
        case insights
        case anomalies
        case overallScore = "overall_score"
        case summaryText = "summary_text"
    }
}


