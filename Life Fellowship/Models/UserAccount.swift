//
//  UserAccount.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import Foundation
import JSONCodable

struct UserAccount: Codable, Identifiable, Hashable {
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var role: String
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName
        case lastName
        case role
        case createdAt

        var stringValue: String {
            switch self {
            case .id: return "userID"
            case .email: return "email"
            case .firstName: return "firstName"
            case .lastName: return "lastName"
            case .role: return "role"
            case .createdAt: return "createdAt"
            }
        }

        init?(stringValue: String) {
            switch stringValue {
            case "userID": self = .id
            case "email": self = .email
            case "firstName": self = .firstName
            case "lastName": self = .lastName
            case "role": self = .role
            case "createdAt": self = .createdAt
            default: return nil
            }
        }

        var intValue: Int? {
            return nil
        }

        init?(intValue: Int) {
            return nil
        }
    }
    
    static func == (lhs: UserAccount, rhs: UserAccount) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.role = try container.decode(String.self, forKey: .role)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
    }
    
    init(id: String, email: String, firstName: String, lastName: String, role: String, createdAt: String) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.createdAt = createdAt
    }
    
    init?(dictionary: [String: AnyCodable]) {
        guard
            let id = dictionary["userID"]?.value as? String,
            let email = dictionary["email"]?.value as? String,
            let firstName = dictionary["firstName"]?.value as? String,
            let lastName = dictionary["lastName"]?.value as? String,
            let role = dictionary["role"]?.value as? String,
            let createdAt = dictionary["createdAt"]?.value as? String
        else {
            return nil
        }
        
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.createdAt = createdAt
    }
}
