// Analytics Service - Communicates with API at api/analytics endpoint
import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()

    private let apiClient = APIClient.shared

    private init() {}

    func getStatistics(
        metricType: MetricType,
        startDate: Date,
        endDate: Date
    ) async throws -> StatisticsResponse {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let start = formatter.string(from: startDate).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let end = formatter.string(from: endDate).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let endpoint = "/api/analytics/\(metricType.rawValue)/statistics?range=custom&start_date=\(start)&end_date=\(end)"

        let response: StatisticsResponse = try await apiClient.request(
            endpoint: endpoint,
            method: .GET,
            responseType: StatisticsResponse.self
        )
        return response
    }
}


