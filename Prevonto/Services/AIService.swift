// AI Service for API calls
import Foundation

class AIService {
    static let shared = AIService()

    private let apiClient = APIClient.shared

    private init() {}

    func getAnomalies(
        metricType: MetricType? = nil,
        daysBack: Int? = nil
    ) async throws -> [Anomaly] {
        var queryItems: [String] = []

        if let metricType = metricType {
            queryItems.append("metric_type=\(metricType.rawValue)")
        }
        if let daysBack = daysBack {
            queryItems.append("days_back=\(daysBack)")
        }

        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        let endpoint = "/api/ai/anomalies\(queryString)"

        let response: [Anomaly] = try await apiClient.request(
            endpoint: endpoint,
            method: .GET,
            responseType: [Anomaly].self
        )
        return response
    }

    func getInsights(daysBack: Int? = nil) async throws -> [Insight] {
        var queryItems: [String] = []

        if let daysBack = daysBack {
            queryItems.append("days_back=\(daysBack)")
        }

        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        let endpoint = "/api/ai/insights\(queryString)"

        let response: [Insight] = try await apiClient.request(
            endpoint: endpoint,
            method: .GET,
            responseType: [Insight].self
        )
        return response
    }

    func getDailySummary(date: Date? = nil) async throws -> DailySummary {
        var queryItems: [String] = []

        if let date = date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = formatter.string(from: date).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            queryItems.append("date=\(dateString)")
        }

        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        let endpoint = "/api/ai/daily-summary\(queryString)"

        let response: DailySummary = try await apiClient.request(
            endpoint: endpoint,
            method: .GET,
            responseType: DailySummary.self
        )
        return response
    }
}


