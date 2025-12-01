// Metrics Service - Communicates with API at api/metrics endpoint
import Foundation

class MetricsService {
    static let shared = MetricsService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - List Metrics
    func listMetrics(
        metricType: MetricType? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        source: DataSource? = nil,
        page: Int = 1,
        pageSize: Int = 50
    ) async throws -> MetricListResponse {
        var queryItems: [String] = []
        
        if let startDate = startDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            queryItems.append("start_date=\(formatter.string(from: startDate).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        if let endDate = endDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            queryItems.append("end_date=\(formatter.string(from: endDate).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        if let source = source {
            queryItems.append("source=\(source.rawValue)")
        }
        queryItems.append("page=\(page)")
        queryItems.append("page_size=\(pageSize)")
        
        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        let path: String
        if let metricType = metricType {
            path = "/api/metrics/\(metricType.rawValue)\(queryString)"
        } else {
            path = "/api/metrics/\(queryString)"
        }
        
        let response: MetricListResponse = try await apiClient.request(
            endpoint: path,
            method: .GET,
            responseType: MetricListResponse.self
        )
        return response
    }
    
    // MARK: - Get Single Metric
    func getMetric(metricType: MetricType, metricId: Int) async throws -> MetricResponse {
        let endpoint = "/api/metrics/\(metricType.rawValue)/\(metricId)"
        let response: MetricResponse = try await apiClient.request(
            endpoint: endpoint,
            method: .GET,
            responseType: MetricResponse.self
        )
        return response
    }
    
    // MARK: - Create Metric
    func createMetric(_ request: MetricCreateRequest) async throws -> MetricResponse {
        let endpoint = "/api/metrics/\(request.metricType.rawValue)"
        let response: MetricResponse = try await apiClient.request(
            endpoint: endpoint,
            method: .POST,
            body: request,
            responseType: MetricResponse.self
        )
        return response
    }
    
    // MARK: - Update Metric
    func updateMetric(metricType: MetricType, metricId: Int, update: MetricUpdateRequest) async throws -> MetricResponse {
        let endpoint = "/api/metrics/\(metricType.rawValue)/\(metricId)"
        let response: MetricResponse = try await apiClient.request(
            endpoint: endpoint,
            method: .PUT,
            body: update,
            responseType: MetricResponse.self
        )
        return response
    }
    
    // MARK: - Delete Metric
    func deleteMetric(metricType: MetricType, metricId: Int) async throws {
        let endpoint = "/api/metrics/\(metricType.rawValue)/\(metricId)"
        let _: EmptyResponse = try await apiClient.request(
            endpoint: endpoint,
            method: .DELETE,
            responseType: EmptyResponse.self
        )
    }
}

