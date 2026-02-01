// Base API Client for handling network requests
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case unauthorized
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized - Please sign in again"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    // Base URL - Currently running API client on iOS Simulator
    // For iOS Simulator: http://localhost:8000
    // For physical device: http://YOUR_MAC_IP:8000 (e.g., http://192.168.1.100:8000)
    private let baseURL = "http://localhost:8000"
    
    private let session: URLSession
    private var accessToken: String?
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Token Management
    func setAccessToken(_ token: String?) {
        self.accessToken = token
    }
    
    // MARK: - Request Building
    private func buildURL(endpoint: String) -> URL? {
        let urlString = "\(baseURL)\(endpoint)"
        return URL(string: urlString)
    }
    
    private func buildRequest(url: URL, method: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authorization header if token exists
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    // MARK: - Generic Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        responseType: T.Type,
        isRetry: Bool = false
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint) else {
            throw APIError.invalidURL
        }
        
        var requestBody: Data?
        if let body = body {
            do {
                let encoder = JSONEncoder()
                // Use ISO8601 date encoding strategy for API compatibility
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                encoder.dateEncodingStrategy = .custom { date, encoder in
                    var container = encoder.singleValueContainer()
                    let dateString = iso8601Formatter.string(from: date)
                    try container.encode(dateString)
                }
                requestBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }
        
        let request = buildRequest(url: url, method: method, body: requestBody)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle HTTP errors
            if httpResponse.statusCode == 401 {
                // Don't retry if this was already a retry or if it's the refresh endpoint itself
                if isRetry || endpoint == "/api/auth/refresh" {
                    throw APIError.unauthorized
                }
                
                // Attempt to refresh access token
                do {
                    _ = try await AuthService.shared.refreshToken()
                    
                    // If successful, retry the original request
                    return try await self.request(
                        endpoint: endpoint,
                        method: method,
                        body: body,
                        responseType: responseType,
                        isRetry: true
                    )
                } catch {
                    // If refresh fails, throw unauthorized
                    throw APIError.unauthorized
                }
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage?.detail)
            }
            
            // Handle empty response (for 204 No Content)
            if httpResponse.statusCode == 204 || data.isEmpty {
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                // If expecting EmptyResponse but got empty data, return it
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
            }
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                
                // Custom date decoding strategy to handle various ISO8601 formats
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Try multiple date formats
                    let formatters: [DateFormatter] = [
                        {
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                            f.timeZone = TimeZone(secondsFromGMT: 0)
                            return f
                        }(),
                        {
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            f.timeZone = TimeZone(secondsFromGMT: 0)
                            return f
                        }()
                    ]
                    
                    for formatter in formatters {
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    
                    // Try ISO8601DateFormatter
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let date = isoFormatter.date(from: dateString) {
                        return date
                    }
                    
                    isoFormatter.formatOptions = [.withInternetDateTime]
                    if let date = isoFormatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Expected date string to be ISO8601-formatted."
                    )
                }
                
                // Special handling for EmptyResponse - if we get any 2xx response, consider it success
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch let decodeError {
                // Debug: Print response data for decoding errors
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("⚠️ DECODING ERROR - Full Response JSON:")
                    print(jsonString)
                    print("---")
                }
                print("⚠️ Decoding error details: \(decodeError)")
                if let decodingError = decodeError as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: Expected \(type), at path: \(context.codingPath)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: Expected \(type), at path: \(context.codingPath)")
                    case .keyNotFound(let key, let context):
                        print("Key not found: \(key.stringValue), at path: \(context.codingPath)")
                    case .dataCorrupted(let context):
                        print("Data corrupted at path: \(context.codingPath), \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                throw APIError.decodingError(decodeError)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Supporting Types
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

struct APIErrorResponse: Decodable {
    let detail: String?
}

struct EmptyResponse: Codable {}

