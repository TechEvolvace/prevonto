// Onboarding Service
import Foundation

class OnboardingService {
    static let shared = OnboardingService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Get Onboarding Data
    func getOnboarding() async throws -> OnboardingResponse {
        let response: OnboardingResponse = try await apiClient.request(
            endpoint: "/api/onboarding/",
            method: .GET,
            responseType: OnboardingResponse.self
        )
        return response
    }
    
    // MARK: - Get Onboarding Progress
    func getOnboardingProgress() async throws -> OnboardingProgressResponse {
        let response: OnboardingProgressResponse = try await apiClient.request(
            endpoint: "/api/onboarding/progress",
            method: .GET,
            responseType: OnboardingProgressResponse.self
        )
        return response
    }
    
    // MARK: - Create or Update Onboarding
    func createOrUpdateOnboarding(_ request: OnboardingRequest) async throws -> OnboardingResponse {
        let response: OnboardingResponse = try await apiClient.request(
            endpoint: "/api/onboarding/",
            method: .POST,
            body: request,
            responseType: OnboardingResponse.self
        )
        return response
    }
    
    // MARK: - Complete Onboarding
    func completeOnboarding() async throws -> OnboardingResponse {
        let response: OnboardingResponse = try await apiClient.request(
            endpoint: "/api/onboarding/complete",
            method: .POST,
            responseType: OnboardingResponse.self
        )
        return response
    }
    
    // MARK: - Helper: Debug Response
    func debugResponse(data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("API Response: \(jsonString)")
        }
    }
}

