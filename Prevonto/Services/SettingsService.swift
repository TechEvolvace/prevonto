// Settings Service
import Foundation

class SettingsService {
    static let shared = SettingsService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Delete Account
    func deleteAccount(password: String?) async throws {
        let request = AccountDeletionRequest(password: password, confirmation: "DELETE MY ACCOUNT")
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/api/settings/delete-account",
            method: .POST,
            body: request,
            responseType: EmptyResponse.self
        )
        
        // Clear tokens after successful deletion
        AuthManager.shared.clearTokens()
    }
}

