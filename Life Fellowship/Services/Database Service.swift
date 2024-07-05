//
//  Database Service.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import Foundation
import Appwrite
import JSONCodable

class DatabaseService {
    private var client: Client
    private var databases: Databases
    private let databaseId: String
    
    init(client: Client, databaseId: String) {
        self.client = client
        self.databases = Databases(client)
        self.databaseId = databaseId
    }
    
    func createDocument<T: Codable>(collectionId: String, documentId: String, data: T, permissions: [String]? = nil) async throws {
        let dictionary = try convertToDictionary(data: data)
        _ = try await databases.createDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: dictionary,
            permissions: permissions
        )
    }
    
    func getDocumentById<T: Codable>(collectionId: String, documentId: String, as type: T.Type) async throws -> T {
        let document = try await databases.getDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            nestedType: T.self
        )
        
        return document.data
    }
    
    func updateDocument<T: Codable>(collectionId: String, documentId: String, data: T, permissions: [String]? = nil) async throws {
        let dictionary = try convertToDictionary(data: data)
        
        _ = try await databases.updateDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId,
            data: dictionary,
            permissions: permissions
        )
    }
    
    func deleteDocument(collectionId: String, documentId: String) async throws {
        _ = try await databases.deleteDocument(
            databaseId: databaseId,
            collectionId: collectionId,
            documentId: documentId
        )
    }
    
    private func convertToDictionary<T: Codable>(data: T) throws -> [String: String] {
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(data)
        } catch {
            print("Failed to encode data: \(error)")
            throw error
        }

        let jsonObject: [String: Any]
        do {
            jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:]
        } catch {
            print("Failed to convert JSON data to dictionary: \(error)")
            throw error
        }
        return jsonObject.reduce(into: [String: String]()) { (result, item) in
            result[item.key] = item.value.self as? String
        }
    }
}
