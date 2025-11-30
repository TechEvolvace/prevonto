// User Model
import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let name: String?
    let authProvider: String
    let isActive: Bool
    let isVerified: Bool
    let emailVerified: Bool
    let consentAccepted: Bool
    let consentVersion: String?
    let consentDate: Date?
    let createdAt: Date
    let lastLogin: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case authProvider = "auth_provider"
        case isActive = "is_active"
        case isVerified = "is_verified"
        case emailVerified = "email_verified"
        case consentAccepted = "consent_accepted"
        case consentVersion = "consent_version"
        case consentDate = "consent_date"
        case createdAt = "created_at"
        case lastLogin = "last_login"
    }
}

// Request Models
struct UserRegisterRequest: Codable {
    let email: String
    let password: String
    let name: String?
}

struct UserLoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct ConsentAcceptanceRequest: Codable {
    let consentType: String
    let version: String
    let accepted: Bool
    
    enum CodingKeys: String, CodingKey {
        case consentType = "consent_type"
        case version
        case accepted
    }
}

struct AccountDeletionRequest: Codable {
    let password: String?
    let confirmation: String
}

