//
//  User.swift
//  AcronymsAppPackageDescription
//
//  Created by Mykhailo Bondarenko on 02.03.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    
    var id: UUID?
    var name: String
    var username: String
    var password: String
    var email: String
    var profilePicture: String?
    var twitterURL: String?
    
    init(name: String, username: String, password: String, email: String, profilePicture: String? = nil, twitterURL: String? = nil) {
        self.name = name
        self.username = username
        self.password = password
        self.email = email
        self.profilePicture = profilePicture
        self.twitterURL = twitterURL
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
    
    final class PublicV2: Codable {
        var id: UUID?
        var name: String
        var username: String
        var twitterURL: String?
        
        init(id: UUID?, name: String, username: String, twitterURL: String? = nil) {
            self.id = id
            self.name = name
            self.username = username
            self.twitterURL = twitterURL
        }
    }
}

extension User {
    
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
    
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
    
    func convertToPublicV2() -> User.PublicV2 {
        return User.PublicV2(id: id, name: name, username: username, twitterURL: twitterURL)
    }
}

extension User.Public: Content {}
extension User.PublicV2: Content {}

extension Future where T: User {
    
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
    
    func convertToPublicV2() -> Future<User.PublicV2> {
        return self.map(to: User.PublicV2.self) { user in
            return user.convertToPublicV2()
        }
    }
}

struct AdminUser: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin", username: "admin", password: hashedPassword, email: "admin@localhost.local")
        return user.save(on: connection).transform(to: ())
    }
    static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
        return .done(on: connection)
    }
}
