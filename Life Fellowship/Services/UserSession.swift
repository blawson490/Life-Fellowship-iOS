//
//  UserSession.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import Foundation
import SwiftUI
import AppwriteModels
import JSONCodable

class UserSession: ObservableObject {
    static let shared = UserSession()
    @Published var user: UserAccount? {
        didSet {
            if user != nil {
                saveUserToDefaults()
            }
        }
    }
    @Published var isLoading: Bool = false
    public var AppwriteService: Appwrite
    private var databaseService: DatabaseService
    
    init() {
        self.AppwriteService = Appwrite()
        self.databaseService = DatabaseService(client: AppwriteService.client, databaseId: Constants.databaseId)
        validateUserSession()
    }
    
    /// Private
    private func validateUserSession() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            do {
                let session = try await AppwriteService.account.getSession(sessionId: "current")
                if isSessionValid(expirationDate: session.expire) {
                    loadUserFromDefaults(userId: session.userId)
                } else {
                    clearSession()
                }
            } catch {
                print("No User Session")
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func saveUserToDefaults() {
        if let user {
            let encoder = JSONEncoder()
            do {
                let encoded = try encoder.encode(user)
                UserDefaults.standard.set(encoded, forKey: "userSession")
            } catch {
                print("DEBUG: Failed to encode user data: \(error)")
            }
        } else {
            print("DEBUG: No user to save")
        }
    }
    
    private func loadUserFromDefaults(userId: String) {
        if let savedUserData = UserDefaults.standard.data(forKey: "userSession") {
            let decoder = JSONDecoder()
            do {
                let loadedUser = try decoder.decode(UserAccount.self, from: savedUserData)
                DispatchQueue.main.async {
                    self.user = loadedUser
                }
            } catch {
                print("DEBUG: Failed to decode user data: \(error)")
                fetchUserFromDatabase(userId: userId)
            }
        } else {
            fetchUserFromDatabase(userId: userId)
        }
    }
    
    private func clearSession() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            do {
                try await AppwriteService.logout()
            } catch {
                print("DEBUG: Error logging out from Appwrite: \(error)")
            }
            
            DispatchQueue.main.async {
                self.user = nil
                UserDefaults.standard.removeObject(forKey: "userSession")
                self.isLoading = false
            }
        }
    }
    
    private func isSessionValid(expirationDate: String) -> Bool {
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let expiration = iso8601Formatter.date(from: expirationDate) {
            let currentDate = Date()
            let isValid = currentDate < expiration
            return isValid
        } else {
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

            if let fallbackExpiration = fallbackFormatter.date(from: expirationDate) {
                let currentDate = Date()
                let isValid = currentDate < fallbackExpiration
                return isValid
            } else {
                print("DEBUG: Failed to parse expiration date with fallback formatter")
            }
        }
        return false
    }
    
    private func fetchUserDetails(userId: String) async throws -> UserAccount {
        let userAccount = try await databaseService.getDocumentById(collectionId: Constants.usersCollection, documentId: userId, as: UserAccount.self)
        return userAccount
    }
    
    private func fetchUserFromDatabase(userId: String) {
        Task {
            do {
                let userAccount = try await fetchUserDetails(userId: userId)
                DispatchQueue.main.async {
                    self.user = userAccount
                    self.saveUserToDefaults()
                    self.isLoading = false
                }
            } catch {
                print("DEBUG: Failed to fetch user details from database: \(error)")
            }
        }
    }
    
    /// Public
    public func registerUserWithEmail(firstName: String, lastName: String, role: String, email: String, password: String) async throws {
        let name = firstName + " " + lastName
        let user = try await AppwriteService.registerWithEmail(email: email, password: password, name: name)
        let userAccount = UserAccount(id: user.id, email: user.email, firstName: firstName, lastName: lastName, role: role, createdAt: user.createdAt)
        try await databaseService.createDocument(collectionId: Constants.usersCollection, documentId: userAccount.id, data: userAccount)
        _ = try await AppwriteService.loginWithEmail(email, password)
        DispatchQueue.main.async {
            self.user = userAccount
        }
    }
    
    public func loginUserWithEmail(email: String, password: String) async throws {
        let session = try await AppwriteService.loginWithEmail(email, password)
        
        let userAccount = try await fetchUserDetails(userId: session.userId)
        DispatchQueue.main.async {
            self.user = userAccount
        }
    }
    
    public func addUserDetailsToDatabase(id: String, firstName: String, lastName: String, role: String, email: String, password: String, createdAt: String) async throws {
        let userAccount = UserAccount(id: id, email: email, firstName: firstName, lastName: lastName, role: role, createdAt: createdAt)
        try await databaseService.createDocument(collectionId: Constants.usersCollection, documentId: userAccount.id, data: userAccount)
        DispatchQueue.main.async {
            self.user = userAccount
        }
    }
    
    public func loginWithPhone(userId: String, code: String) async throws {
        let session = try await AppwriteService.createPhoneToken(userId: userId, secret: code)
        let userAccount = try await fetchUserDetails(userId: session.userId)
        DispatchQueue.main.async {
            self.user = userAccount
        }
    }
    
    public func verifyPhoneCode(userId: String, code: String) async throws -> Bool {
        let session = try await AppwriteService.createPhoneToken(userId: userId, secret: code)
        // Check if userAccount exists
        let userAccount = try await fetchUserDetails(userId: session.userId)
        if userAccount.email != "" {
            return true
        }
        return false
    }
    
    public func getUserId(phone: String) async throws -> String {
        let token = try await AppwriteService.getPhoneToken(phone: phone)
        
        return token.userId
    }
    
    public func updateUserName(name: String) async throws {
        _ = try await AppwriteService.updateUserName(name: name)
    }
    
    public func updateUserEmail(email: String, password: String) async throws {
        _ = try await AppwriteService.updateUserEmail(email: email, password: password)
    }
    
    private func createUserPassword(password: String) async throws {
        _ = try await AppwriteService.createUserPassword(password: password)
    }
    
    public func updateUserPassword(oldPassword: String, newPassword: String) async throws {
        _ = try await AppwriteService.updateUserPassword(password: newPassword, oldPassword: oldPassword)
    }
    
    public func updateNewPhoneUser(firstName: String, lastName: String, email: String, password: String) async throws {
        let token = try await AppwriteService.updateUserName(name: "\(firstName) \(lastName)")
        try await createUserPassword(password: password)
        try await updateUserEmail(email: email, password: password)
        try await addUserDetailsToDatabase(id: token.id, firstName: firstName, lastName: lastName, role: "user", email: email, password: password, createdAt: token.createdAt)
        let userAccount = UserAccount(id: token.id, email: email, firstName: firstName, lastName: lastName, role: "user", createdAt: token.createdAt)
        DispatchQueue.main.async {
            self.user = userAccount
        }
    }
    
    public func logoutUser() async throws {
        self.clearSession()
    }
}
