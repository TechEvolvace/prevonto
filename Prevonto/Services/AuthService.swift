// Authentication Service - Handle authentication processes
import Foundation

// Can communicate with API at /api/auth and /api/settings endpoints
class AuthService {
    static let shared = AuthService()
    
    private let apiClient = APIClient.shared
    private let authManager = AuthManager.shared
    
    private init() {}
    
    // MARK: - Registration
    func register(email: String, password: String, name: String?) async throws -> TokenResponse {
        let request = UserRegisterRequest(email: email, password: password, name: name)
        let response: TokenResponse = try await apiClient.request(
            endpoint: "/api/auth/register",
            method: .POST,
            body: request,
            responseType: TokenResponse.self
        )
        
        // Save tokens
        authManager.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        
        return response
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> TokenResponse {
        let request = UserLoginRequest(email: email, password: password)
        let response: TokenResponse = try await apiClient.request(
            endpoint: "/api/auth/login",
            method: .POST,
            body: request,
            responseType: TokenResponse.self
        )
        
        // Save tokens
        authManager.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        
        return response
    }
    
    // MARK: - Get Current User
    func getCurrentUser() async throws -> User {
        let user: User = try await apiClient.request(
            endpoint: "/api/auth/me",
            method: .GET,
            responseType: User.self
        )
        return user
    }
    
    // MARK: - Refresh Token
    func refreshToken() async throws -> TokenResponse {
        guard let refreshToken = authManager.getRefreshToken() else {
            throw APIError.unauthorized
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: TokenResponse = try await apiClient.request(
            endpoint: "/api/auth/refresh",
            method: .POST,
            body: request,
            responseType: TokenResponse.self
        )
        
        // Save new tokens
        authManager.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
        
        return response
    }
    
    // MARK: - Logout
    func logout() async throws {
        guard let refreshToken = authManager.getRefreshToken() else {
            // If no refresh token, just clear local tokens
            authManager.clearTokens()
            return
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/api/auth/logout",
            method: .POST,
            body: request,
            responseType: EmptyResponse.self
        )
        
        // Clear local tokens
        authManager.clearTokens()
    }
    
    // MARK: - Accept Consent
    func acceptConsent(consentType: String = "hipaa_consent", version: String = "1.0") async throws {
        let request = ConsentAcceptanceRequest(consentType: consentType, version: version, accepted: true)
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/api/auth/consent",
            method: .POST,
            body: request,
            responseType: EmptyResponse.self
        )
    }
    
    // MARK: - Update Profile
    func updateProfile(name: String?, email: String?) async throws -> User {
        let request = UserUpdateRequest(name: name, email: email)
        let user: User = try await apiClient.request(
            endpoint: "/api/settings/profile",
            method: .PUT,
            body: request,
            responseType: User.self
        )
        return user
    }
}

