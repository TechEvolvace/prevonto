// Medication Search Response Model
import Foundation

struct MedicationSearchResult: Codable {
    let name: String
    let genericName: String?
    let category: String?
    let matchType: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case genericName = "generic_name"
        case category
        case matchType = "match_type"
    }
}

struct MedicationSearchResponse: Codable {
    let query: String
    let results: [MedicationSearchResult]
    let totalResults: Int
    let limit: Int
    
    enum CodingKeys: String, CodingKey {
        case query
        case results
        case totalResults = "total_results"
        case limit
    }
}

