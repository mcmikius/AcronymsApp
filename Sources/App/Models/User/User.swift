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
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
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
}

extension User {

    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }

    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
}

extension User.Public: Content {}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}