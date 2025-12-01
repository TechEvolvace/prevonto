// Authentication Manager for token storage and management
import Foundation
import Security

class AuthManager: ObservableObject {
    nonisolated(unsafe) static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published private(set) var accessToken: String?
    
    private let accessTokenKey = "com.prevonto.accessToken"
    private let refreshTokenKey = "com.prevonto.refreshToken"
    
    private init() {
        loadTokens()
    }
    
    // MARK: - Token Storage (Keychain)
    func saveTokens(accessToken: String, refreshToken: String) {
        saveToKeychain(key: accessTokenKey, value: accessToken)
        saveToKeychain(key: refreshTokenKey, value: refreshToken)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.accessToken = accessToken
            self.isAuthenticated = true
            APIClient.shared.setAccessToken(accessToken)
        }
    }
    
    func loadTokens() {
        let token = loadFromKeychain(key: accessTokenKey)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.accessToken = token
            self.isAuthenticated = token != nil
            if let token = token {
                APIClient.shared.setAccessToken(token)
            }
        }
    }
    
    nonisolated func getRefreshToken() -> String? {
        return loadFromKeychain(key: refreshTokenKey)
    }
    
    func clearTokens() {
        deleteFromKeychain(key: accessTokenKey)
        deleteFromKeychain(key: refreshTokenKey)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.accessToken = nil
            self.isAuthenticated = false
            APIClient.shared.setAccessToken(nil)
        }
    }
    
    // MARK: - Keychain Operations
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item if any
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

