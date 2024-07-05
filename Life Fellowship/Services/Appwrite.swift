//
//  Appwrite.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import Foundation
import Appwrite
import JSONCodable

class Appwrite {
    var client: Client
    var account: Account
    
    private func verifyEmail() async throws {
        let token = try await account.createVerification(url: "https://lifefellowship.appwrite.io/verify")
        print("Verification token: \(token)")
    }
    
    public init() {
        self.client = Client()
            .setEndpoint(Constants.endpoint)
            .setProject(Constants.projectId)
        
        self.account = Account(client)
    }
    
    public func registerWithEmail(
        email: String,
        password: String,
        name: String
    ) async throws -> User<[String: AnyCodable]> {
        try await account.create(userId: ID.unique(), email: email, password: password, name: name)
    }
    
    public func createPhoneToken(userId: String, secret: String) async throws -> Session {
        let session = try await account.createSession(userId: userId, secret: secret)
        return session
    }
    
    public func getPhoneToken(phone: String) async throws -> Token{
        let token = try await account.createPhoneToken(userId: ID.unique(), phone: phone)
        print(token)
        return token
    }
    
    public func loginWithEmail(
        _ email: String,
        _ password: String
    ) async throws -> Session {
        try await account.createEmailPasswordSession(
            email: email,
            password: password
        )
    }
    
    public func updateUserName(name: String) async throws -> User<[String: AnyCodable]> {
        let token = try await account.updateName(name: name)
        return token
    }
    
    public func updateUserEmail(email: String, password: String) async throws -> User<[String: AnyCodable]> {
        let token = try await account.updateEmail(email: email, password: password)
        return token
    }
    
    public func createUserPassword(password: String) async throws -> User<[String: AnyCodable]> {
        let token = try await account.updatePassword(password: password)
        return token
    }
    
    public func updateUserPassword(password: String, oldPassword: String) async throws -> User<[String: AnyCodable]>  {
        let token = try await account.updatePassword(password: password, oldPassword: oldPassword)
        return token
    }
    
    public func logout() async throws {
        /// Session
        let _ = try await account.deleteSession(
            sessionId: "current"
        )
    }
    
    public func getUserDetails() async throws -> User<[String: AnyCodable]> {
        try await account.get()
    }
}
