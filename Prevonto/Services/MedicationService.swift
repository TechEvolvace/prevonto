// Medication Service
import Foundation

class MedicationService {
    static let shared = MedicationService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Search Medications
    func searchMedications(query: String, limit: Int = 20) async throws -> MedicationSearchResponse {
        guard query.count >= 2 else {
            throw APIError.httpError(statusCode: 400, message: "Search query must be at least 2 characters")
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let endpoint = "/api/medications/search?query=\(encodedQuery)&limit=\(limit)"
        
        let response: MedicationSearchResponse = try await apiClient.request(
            endpoint: endpoint,
            method: .GET,
            responseType: MedicationSearchResponse.self
        )
        
        return response
    }
    
    // MARK: - Get Medication Details
    func getMedicationDetails(name: String) async throws -> MedicationSearchResult {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let endpoint = "/api/medications/details/\(encodedName)"
        
        let response: MedicationSearchResult = try await apiClient.request(
            endpoint: endpoint,
            method: .GET,
            responseType: MedicationSearchResult.self
        )
        
        return response
    }
}

